enum OutputType {
    RunOut,
    LLVMIR,
    CTranslation
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
    var status : int
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

struct CompilationResult {
    var output : std::string
    var error_msg : *char = null
}

public func compile_files(c_output : bool, files : &mut std::vector<std::pair<std::string, std::string>>) : CompilationResult {

    var temp : [13]char
   // use two independent randoms so the 12-char id is not duplicated
    var r1 = generate_random_32bit();
    var r2 = generate_random_32bit();
    base64_encode_32bit(r1, &mut temp[0]);   // writes temp[0..5]
    base64_encode_32bit(r2, &mut temp[6]);   // writes temp[6..11]
    temp[12] = '\0';

    // prefer a string object so later code can safely use .data()
    var dir_name = std::string_view(&temp[0], 12);

    // create the directory
    var created = fs::create_dir(dir_name.data())
    if(created is std::Result.Err) {
        printf("couldn't create directory %s\n", dir_name.data());
        var result = CompilationResult()
        result.error_msg = "couldn't create a directory"
        return result;
    }

    // writing the files
    while(!files.empty()) {
        var file = files.take_last()

        var filePath = std::string()
        filePath.append_view(dir_name)
        filePath.append('/');
        filePath.append_string(file.first)

        if(file.second.size() > 5000) {
            var result = CompilationResult()
            result.error_msg = "a file content cannot be larger than 5000 characters"
            return result;
        }

        // TODO: verify the file name
        var written = fs::write_text_file(filePath.data(), file.second.data() as *u8, file.second.size())
        if(written is std::Result.Err) {
            var Err(err) = written else unreachable
            var msg = err.message()
            printf("couldn't create the file at %s because %s\n", filePath.data(), msg.data());
            var result = CompilationResult();
            result.error_msg = "couldn't create the file"
            return result;
        }

    }

    // calculating .mod file path
    var modFilePath = std::string()
    modFilePath.append_view(dir_name)
    modFilePath.append_view(std::string_view("/chemical.mod"))

    // build directory path
    var buildDirPath = std::string()
    buildDirPath.append_view(dir_name)

    // output file path
    var outputFilePath = std::string()
    outputFilePath.append_view(dir_name)
    outputFilePath.append_view(std::string_view("/build.exe"))

    // building the command
    var command = std::vector<std::string>();
    command.push(std::string("chemical"))
    command.push(modFilePath)
    command.push(std::string("-o"))
    command.push(outputFilePath.copy())
    if(c_output) {
        command.push(std::string("-jt"))
        command.push(std::string("2c"))
    } else {
        command.push(std::string("-jt"))
        command.push(std::string("inter"))
        command.push(std::string("-out-ll-all"))
    }
    command.push(std::string("--no-cache"))

    var procResult = launch_exe(command)
    if(procResult.success) {
        // printing the output
        printf("output received from command %s\n", procResult.output.data());

        // calculating the path to output file
        var finalOutPath = std::string()
        if(c_output) {
            finalOutPath.append_string(outputFilePath)
        } else {
            finalOutPath.append_view(dir_name)
            finalOutPath.append_view(std::string_view("/build/main/llvm_ir.ll"))
        }

        // read the entire file (if can)
        var result = fs::read_entire_file(finalOutPath.data())
        if(result is std.Result.Err) {
            var Err(err) = result else unreachable
            var msg = err.message()
            printf("error reading file at '%s' with message '%s'\n", finalOutPath.data(), msg.data());
            var result = CompilationResult();
            result.error_msg = "couldn't read the output file"
            return result;
        }

        var Ok(value) = result else unreachable
        var cres = CompilationResult()
        cres.output.append_view(std::string_view(value.data() as *char, value.size()))

        var rem_res = fs::remove_dir_all_recursive(dir_name.data())
        if(rem_res is std.Result.Err) {
            var Err(err) = rem_res else unreachable
            var msg = err.message()
            printf("error removing directory at '%s' with message '%s'\n", dir_name.data(), msg.data());
        }

        return cres

    } else {
        // printing the output
        printf("output received from command %s\n", procResult.output.data());

        var rem_res = fs::remove_dir_all_recursive(dir_name.data())
        if(rem_res is std.Result.Err) {
            var Err(err) = rem_res else unreachable
            var msg = err.message()
            printf("error removing directory at '%s' with message '%s'\n", dir_name.data(), msg.data());
        }

    }

    return CompilationResult();
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
                        if(number_str.equals_view(std::string_view("1"))) {
                            ot = OutputType.RunOut
                        } else if(number_str.equals_view(std::string_view("1"))) {
                            ot = OutputType.LLVMIR
                        } else if(number_str.equals_view(std::string_view("2"))) {
                            ot = OutputType.CTranslation
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
                        var result = compile_files(ot == OutputType.CTranslation, files)
                        if(result.error_msg != null) {
                            res.write_view("""{ "type" : "error", "message" : "internal error occurred" }""")
                            return;
                        }

                        // preparing the final view
                        var final = std::string()
                        var builder = JsonStringBuilder{ ptr : final }
                        final.append_view(std::string_view("{ \"type\" : \"output\", \"output\" : "))
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

    return 0;
}