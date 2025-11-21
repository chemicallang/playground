enum OutputType {
    RunOut,
    LLVMIR,
    CTranslation,
    CompilerOutput,
    AssemblyOutput
}

public func (value : &mut JsonValue) take_string() : std::string {
    if(value !is JsonValue.String) return std::string()
    var String(str) = value else unreachable
    // TODO: can't move while pattern matching
    var my_str = std::string()
    my_str.append_string(str)
    return my_str;
}

// Small cross-platform executor: returns (exit_code, combined stdout+stderr)
public struct ExecResult {
    var status : int = 0
    var output : std::string
}

// minimal externs
if (def.windows) {
    @extern public func _popen(cmd : *char, mode : *char) : *mut FILE;
    @extern public func _pclose(p : *mut FILE) : int;
} else {
    // @extern public func popen(cmd : *char, mode : *char) : *void;
    // @extern public func pclose(p : *void) : int;
}

public func run_command(cmd_view : std::string_view) : ExecResult {
    // build command and redirect stderr into stdout
    var cmd = std::string()
    cmd.append_view(cmd_view)
    cmd.append_view(std::string_view(" 2>&1"))

    // open pipe
    var pipe : *mut FILE = null
    comptime if (def.windows) {
        pipe = _popen(cmd.data(), "r")
    } else {
        pipe = popen(cmd.data(), "r")
    }
    if (pipe == null) {
        var r = ExecResult()
        r.status = -1
        r.output = std::string("popen failed")
        return r
    }

    // read all output
    var out = std::string()
    var buf : [4096]u8
    memset(&mut buf, 0, sizeof(buf))
    while (true) {
        var n = fread(&mut buf[0], 1 as size_t, 4096 as size_t, pipe as *mut FILE)
        if (n == 0) { break; }
        // append raw bytes (cast to char pointer)
        out.append_with_len((&buf[0]) as *char, n as size_t)
    }

    // close and determine status
    var raw_status : int = 0
    comptime if (def.windows) { raw_status = _pclose(pipe) } else { raw_status = pclose(pipe) }

    // normalize exit code: on POSIX pclose returns wait status; extract WEXITSTATUS
    var code = raw_status
    comptime if (!def.windows) {
        // if pclose failed it may return -1; otherwise extract high byte
        if (raw_status >= 0) {
            code = (raw_status >> 8) & 0xFF
        } else {
            code = -1
        }
    }

    var res = ExecResult()
    res.status = code
    res.output = out
    return res
}

const BASE64_CHARS : char[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789__";

func base64_encode_32bit(hash : u32, out : *mut char) {
    for (var i = 0; i < 6; i++) {
        out[5 - i] = BASE64_CHARS[hash & 0x3F]; // Extract 6 bits
        hash >>= 6;
    }
}

@extern
public func rand() : int;

func generate_random_32bit() : u32 {
    return (rand() as u32 << 16) | rand() as u32;
}

public func main(argc : int, argv : **char) : int {

    // create default config (you can customize fields)
    var cfg = server.ServerConfig();
    cfg.worker_count = std.concurrent.hardware_threads() as uint;
    cfg.header_timeout_secs = 5;
    cfg.max_header_bytes = 64u * 1024u;
    cfg.max_headers = 512u;
    cfg.max_body_bytes = 10u * 1024u * 1024u;

    var srv = server.Server(cfg);

    var prod_logo = std::string_view("Logo.png")
    var dev_logo = std::string_view("lang/compiled/playground/src/assets/Logo.png")
    var which_logo = if(def.debug) dev_logo else prod_logo

    // checkout the logo
    printf("logo path : %s\n", which_logo.data());

    var main_page = HtmlPage()
    MainPage(main_page)
    main_page.appendTitle("Chemical | Programming Language")
    main_page.appendPngFavicon("Logo.png")
    var completeMainPage = main_page.toString();

    var pgPage = HtmlPage()
    PlaygroundPage(pgPage)
    pgPage.appendTitle("Playground | Chemical")
    pgPage.appendPngFavicon("Logo.png")
    var completePgPage = pgPage.toString();

    // Register root handler
    srv.router.add("GET", "/", (|&completeMainPage|(req,res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"));
        res.write_view(completeMainPage.to_view());
    }));

    // Register root handler
    srv.router.add("GET", "/playground", (|&completePgPage|(req,res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"));
        res.write_view(completePgPage.to_view());
    }));

    srv.router.add("GET", "/Logo.png", |&which_logo|(req, res) => {
        if (!res.send_file(which_logo, std::string_view("image/png"))) {
            res.status = 404u;
            res.set_header_view(std::string_view("Content-Type"), std::string_view("text/plain"));
            res.write_string(std::string::make_no_len("Not Found\n"));
        }
    })

    srv.router.add("POST", "/submit", (req, res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("application/json; charset=utf-8"));
        var body_opt = req.body.read_to_string()
        if(body_opt is std.Option.Some) {
            var Some(value) = body_opt else unreachable
            var parser = JsonParser(128, 4096)
            var astHandler = ASTJsonHandler()
            var result = parser.parse(value.data(), value.size(), astHandler)
            if(result.ok) {
                if(astHandler.root is JsonValue.Object) {
                    var Object(values) = astHandler.root else unreachable
                    const outputType = values.get_ptr(std::string("outputType"))
                    if(outputType != null && outputType is JsonValue.Number) {
                        var Number(number_str) = *outputType else unreachable;
                        var ot = OutputType.CTranslation
                        if(number_str.equals_view(std::string_view("0"))) {
                            ot = OutputType.RunOut
                        } else if(number_str.equals_view(std::string_view("1"))) {
                            ot = OutputType.LLVMIR
                        } else if(number_str.equals_view(std::string_view("2"))) {
                            ot = OutputType.CTranslation
                        } else if(number_str.equals_view(std::string_view("3"))) {
                            ot = OutputType.CompilerOutput
                        } else if(number_str.equals_view(std::string_view("4"))) {
                            ot = OutputType.AssemblyOutput
                        } else {
                            res.write_view("""{ "type" : "error", "message" : "unknown output type" }""")
                            return;
                        }
                        // list of name and content pair of files
                        var files = std::vector<std::pair<std::string, std::string>>()
                        const filesPtr = values.get_ptr(std::string("files"))
                        if(filesPtr != null && filesPtr is JsonValue.Array) {
                            var Array(values) = *filesPtr else unreachable
                            while(!values.empty()) {
                                var obj = values.take_last()
                                if(obj is JsonValue.Object) {
                                    var Object(entries) = obj else unreachable
                                    const contentPtr = entries.get_ptr(std::string("content"))
                                    if(contentPtr != null && contentPtr is JsonValue.String) {
                                        const namePtr = entries.get_ptr(std::string("name"))
                                        if(namePtr != null && namePtr is JsonValue.String) {
                                            files.push(std::pair<std::string, std::string> {
                                                first : namePtr.take_string(),
                                                second : contentPtr.take_string()
                                            })
                                        }
                                    }
                                }
                            }
                        }
                        if(files.empty()) {
                            res.write_view("""{ "type" : "error", "message" : "no files given" }""")
                            return;
                        }


                        // parse optional settings object
                        var settings = CompileSettings();
                        const settingsPtr = values.get_ptr(std::string("settings"));
                        if (settingsPtr != null && settingsPtr is JsonValue.Object) {
                            var Object(smap) = *settingsPtr else unreachable;
                            const s_debug_ir = smap.get_ptr(std::string("debug_ir"));
                            if (s_debug_ir != null && s_debug_ir is JsonValue.Bool) { var Bool(b) = *s_debug_ir else unreachable; settings.debug_ir = b; }
                            const s_verbose = smap.get_ptr(std::string("verbose"));
                            if (s_verbose != null && s_verbose is JsonValue.Bool) { var Bool(b) = *s_verbose else unreachable; settings.verbose = b; }
                            const s_use_tcc = smap.get_ptr(std::string("use_tcc"));
                            if (s_use_tcc != null && s_use_tcc is JsonValue.Bool) { var Bool(b) = *s_use_tcc else unreachable; settings.use_tcc = b; }
                            const s_fno = smap.get_ptr(std::string("fno_unwind_tables"));
                            if (s_fno != null && s_fno is JsonValue.Bool) { var Bool(b) = *s_fno else unreachable; settings.fno_unwind_tables = b; }
                            const s_mode = smap.get_ptr(std::string("mode"));
                            if (s_mode != null && s_mode is JsonValue.String) { settings.mode = s_mode.take_string(); }
                            const s_lto = smap.get_ptr(std::string("lto"));
                            if (s_lto != null && s_lto is JsonValue.Bool) { var Bool(b) = *s_lto else unreachable; settings.lto = b; }
                            const s_bench = smap.get_ptr(std::string("benchmark"));
                            if (s_bench != null && s_bench is JsonValue.Bool) { var Bool(b) = *s_bench else unreachable; settings.benchmark = b; }
                            const s_bmfiles = smap.get_ptr(std::string("bm_files"));
                            if (s_bmfiles != null && s_bmfiles is JsonValue.Bool) { var Bool(b) = *s_bmfiles else unreachable; settings.bm_files = b; }
                            const s_bmmod = smap.get_ptr(std::string("bm_modules"));
                            if (s_bmmod != null && s_bmmod is JsonValue.Bool) { var Bool(b) = *s_bmmod else unreachable; settings.bm_modules = b; }
                        }

                        var result = compile_files_in_docker(settings, ot, files)
                        if(result.error_msg != null) {
                            printf("error in compile_files: %s\n", result.error_msg);
                            res.write_view("""{ "type" : "error", "message" : "internal error occurred" }""")
                            return;
                        }

                        // preparing the final view
                        var final = std::string()
                        var builder = JsonStringBuilder{ ptr : final }
                        final.append_view(std::string_view("{ \"type\" : \"output\", \"status\" : "))
                        final.append_integer(result.status)
                        final.append_view(std::string_view(", \"output\" : "))
                        escape_string_into(builder, result.output)
                        final.append_view(std::string_view(" }"))

                        res.write_view(final.to_view())
                        return;
                    }
                }
            }
        }
        res.write_view("""{ "type" : "error", "message" : "couldn't parse json" }""")
    })

    // Start serving (blocks)
    srv.serve();

    printf("stopped serving\n")

    return 0;
}