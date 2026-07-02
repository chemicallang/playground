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
    my_str.append_string(&str)
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
    cmd.append_view(&cmd_view)
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
    memset(&raw mut buf, 0, sizeof(buf))
    while (true) {
        var n = fread(&raw mut buf[0], 1 as size_t, 4096 as size_t, pipe as *mut FILE)
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

func generate_random_32bit() : u32 {
    return (rand() as u32 << 16) | rand() as u32;
}

public func main(argc : int, argv : **char) : int {

    // create default config (you can customize fields)
    var cfg = server.ServerConfig();
    var hw_threads = std.concurrent.hardware_threads() as uint;
    cfg.worker_count = if (hw_threads < 4u) 4u else hw_threads;
    cfg.header_timeout_secs = 5;
    cfg.max_header_bytes = 64u * 1024u;
    cfg.max_headers = 512u;
    cfg.max_body_bytes = 10u * 1024u * 1024u;

    var srv = server.Server(cfg);

    var prod_logo = std::string_view("Logo.png")
    var dev_logo = std::string_view("lang/compiled/playground/src/assets/Logo.png")
    var which_logo = if(def.debug) dev_logo else prod_logo

    var prod_favicon = std::string_view("Favicon.png")
    var dev_favicon = std::string_view("lang/compiled/playground/src/assets/Favicon.png")
    var which_favicon = if(def.debug) dev_favicon else prod_favicon

    // checkout the logo
    printf("logo path : %s\n", which_logo.data());

    var main_page = HtmlPage()
    MainPage(&mut main_page)
    main_page.appendTitle("Chemical | Programming Language")
    main_page.appendPngFavicon("Favicon.png")
    var completeMainPage = main_page.toString();

    var pgPage = HtmlPage()
    PlaygroundPage(&mut pgPage)
    pgPage.appendTitle("Playground | Chemical")
    pgPage.appendPngFavicon("Favicon.png")
    var completePgPage = pgPage.toString();

    // Register root handler
    srv.router.add("GET", "/", (|&completeMainPage|(req,res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"));
        res.write_view(completeMainPage.to_view());
    }));

    // HEAD request handler (used by Microsoft to check domain ownership)
    srv.router.add("HEAD", "/", (req,res) => {
        res.set_cors(std::string_view("*"));
        res.status = 200u;
        res.write_view(std::string_view());
    })

    // Register root handler
    srv.router.add("GET", "/playground", (|&completePgPage|(req,res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"));
        res.write_view(completePgPage.to_view());
    }));

    srv.router.add("GET", "/Favicon.png", |&which_favicon|(req, res) => {
        if (!res.send_file(which_favicon, std::string_view("image/png"))) {
            res.status = 404u;
            res.set_header_view(std::string_view("Content-Type"), std::string_view("text/plain"));
            res.write_string(std::string::make_no_len("Not Found\n"));
        }
    })

    srv.router.add("GET", "/Logo.png", |&which_logo|(req, res) => {
        if (!res.send_file(which_logo, std::string_view("image/png"))) {
            res.status = 404u;
            res.set_header_view(std::string_view("Content-Type"), std::string_view("text/plain"));
            res.write_string(std::string::make_no_len("Not Found\n"));
        }
    })

    srv.router.add("GET", "/install.sh", (req, res) => {
        res.status = 302u;
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/download.sh"));
        res.write_view(std::string_view("Redirecting to install script...\n"));
    })

    srv.router.add("GET", "/install.ps1", (req, res) => {
        res.status = 302u;
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/download.ps1"));
        res.write_view(std::string_view("Redirecting to install script...\n"));
    })

    srv.router.add("GET", "/test.sh", (req, res) => {
        res.status = 302u;
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/run-tests.sh"));
        res.write_view(std::string_view("Redirecting to test script...\n"));
    })

    srv.router.add("GET", "/test.ps1", (req, res) => {
        res.status = 302u;
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/run-tests.ps1"));
        res.write_view(std::string_view("Redirecting to test script...\n"));
    })

    srv.router.add("POST", "/submit", (req, res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("application/json; charset=utf-8"));
        var body_opt = req.body.read_to_string()
        if(body_opt is std.Option.Some) {
            var Some(value) = body_opt else unreachable
            var parser = JsonParser(128, 4096)
            var astHandler = ASTJsonHandler()
            var result = parser.parse(value.data(), value.size(), &mut astHandler)
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
                            var Array(values2) = *filesPtr else unreachable
                            while(!values2.empty()) {
                                var obj = values2.take_last()
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
                            const s_version = smap.get_ptr(std::string("version"));
                            if (s_version != null && s_version is JsonValue.String) {
                                var String(v_str) = *s_version else unreachable;
                                switch(fnv1_hash_view(v_str.to_view())) {
                                    comptime_fnv1_hash("32"), default => {
                                        settings.version = 32;
                                    }
                                    comptime_fnv1_hash("30") => {
                                        settings.version = 30;
                                    }
                                    comptime_fnv1_hash("29") => {
                                        settings.version = 29;
                                    }
                                }
                            }
                        }

                        var result2 = compile_files_in_docker(&settings, ot, &mut files)
                        if(!result2.error_msg.empty()) {
                            var err_json = std::string()
                            var builder = JsonStringBuilder{ ptr : &mut err_json }
                            
                            err_json.append_view(std::string_view("""{ "type" : "error", "message" : """))
                            
                            var msg_str = std::string()
                            msg_str.append_view(result2.error_msg.to_view())
                            escape_string_into(&builder, &msg_str)
                            
                            err_json.append_view(std::string_view(""" }"""))
                            
                            res.write_view(err_json.to_view())
                            // cleanup string view from result2.error_msg if needed, but here it's likely a static string or managed by docker result logic
                            return;
                        }

                        // preparing the final view
                        var final = std::string()
                        var builder = JsonStringBuilder{ ptr : &mut final }
                        final.append_view(std::string_view("{ \"type\" : \"output\", \"status\" : "))
                        final.append_integer(result2.status)
                        final.append_view(std::string_view(", \"output\" : "))
                        escape_string_into(&builder, &result2.output)
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