// result returned from compiling in Docker
public struct DockerCompilationResult {
    var status : int = 0              // exit code of compiler inside container (or -1 on internal error)
    var stdout_and_stderr : std::string
    var output : std::string // e.g. llvm_ir.ll or compiled binary (text here)
    var error_msg : *char = null
}

// new: compile settings carried from the UI
public struct CompileSettings {
    var use_tcc : bool = false;
    var debug_ir : bool = false;
    var fno_unwind_tables : bool = false;
    var mode : std::string
    var lto : bool = false;
    var benchmark : bool = false;
    var bm_files : bool = false;
    var bm_modules : bool = false;
}

func write_entrypoint_script_new(settings : &CompileSettings, outputType : OutputType, host_dir : std::string) : std::Result<UnitTy, fs::FsError> {

    // script path
    var script_path = std::string()
    script_path.append_string(host_dir)
    script_path.append_view(std::string_view("/run_compile.sh"))

    // script content (POSIX shell). Note: on Windows docker images you'll still run this inside *container* POSIX shell if image has sh.
    var content = std::string()
    content.append_view(std::string_view("#!/bin/sh\n"))
    content.append_view(std::string_view("'chemical' 'chemical.mod' '--no-cache' -o 'build.exe'"))

    if(!settings.mode.empty()) {
        // allowed modes list
        const modesAllowed : [6]std::string_view = [
            std::string_view("debug_quick"),
            std::string_view("debug"),
            std::string_view("debug_complete"),
            std::string_view("release"),
            std::string_view("release_fast"),
            std::string_view("release_small")
        ];
        var okMode = false;
        for (var i=0; i < 6; i++) {
            if (settings.mode.equals_view(modesAllowed[i])) { okMode = true; break; }
        }
        if (okMode) {
            // quote mode
            content.append_view(std::string_view(" --mode '"));
            content.append_string(settings.mode);
            content.append_view(std::string_view("'"));
        }
    }

    // debug-ir
    if (settings.debug_ir) {
        content.append_view(std::string_view(" --debug-ir"));
    }

    // fno-unwind-tables: if true, append flag to disable unwind tables (adjust flag name to actual compiler flag)
    if (settings.fno_unwind_tables) {
        content.append_view(std::string_view(" --fno-unwind-tables"));
    }

    // lto
    if (settings.lto) {
        content.append_view(std::string_view(" --lto"));
    }

    // benchmark flags
    if(outputType == OutputType.CompilerOutput) {
        if (settings.benchmark) { content.append_view(std::string_view(" --benchmark")); }
        if (settings.bm_files) { content.append_view(std::string_view(" --bm-files")); }
        if (settings.bm_modules) { content.append_view(std::string_view(" --bm-modules")); }
    }

    // check use tcc
    if(outputType == OutputType.RunOut || outputType == OutputType.CompilerOutput) {
        if(settings.use_tcc) {
            content.append_view(" --use-tcc")
        }
    }

    if(outputType == OutputType.CTranslation) {
        content.append_view(std::string_view(" -jt"))
        content.append_view(std::string_view(" 2c"))
    } else if(outputType == OutputType.LLVMIR) {
        content.append_view(std::string_view(" -jt"))
        content.append_view(std::string_view(" inter"))
        content.append_view(std::string_view(" -out-ll-all"))
    } else if(outputType == OutputType.AssemblyOutput) {
        content.append_view(std::string_view(" -jt"))
        content.append_view(std::string_view(" inter"))
        content.append_view(std::string_view(" -out-asm-all"))
    } else if(outputType == OutputType.RunOut) {
        // send the compiler output to nowhere
        content.append_view(std::string_view(" > /dev/null 2>&1\n"))
        // execute the build.exe (only if compiler command returned status code 0)
        content.append_view(std::string_view("status=$?\n"))
        content.append_view(std::string_view("if [ $status -ne 0 ]; then\n\texit $status\nfi\n"))
        content.append_view(std::string_view("exec ./build.exe\n"))
    } else {
        // case: CompilerOutput
        // get both output stdout and stderr
        content.append_view(std::string_view(" 2>&1\n"))
        // automatically produce executable and get the compiler output
        // we must get the complete ouptut
    }


    // write the file
    var w = fs::write_text_file(script_path.data(), content.data() as *u8, content.size())
    if (w is std.Result.Err) { return w }

    // set the permissions on the script file
    var perm = fs::set_permissions(script_path.data(), 0o755)
    if(perm is std.Result.Err) { return perm }

    // if hosting on POSIX we would chmod +x, but inside container we will invoke "sh /work/run_compile.sh" so executable bit not strictly necessary.
    return std.Result.Ok(UnitTy{})
}

func shell_escape_single_quotes(orig: std::string) : std::string {
    var out = std::string();
    // For every ' -> replace with '\'' (that's: single-quote, double-quote, single-quote)
    // Implementation: replace ' with '"'"'
    for (var i = 0; i < orig.size(); i += 1) {
        const c = orig.get(i as size_t);
        if (c == ('\'' as u8)) {
            out.append_view(std::string_view("'\"'\"'")); // yields: '\'' when concatenated in shell
        } else {
            out.append(c);
        }
    }
    return out;
}

struct docker_worker_captured {
    var docker_cmd : *std::string
    var promise : *mut std.concurrent.Promise<ExecResult>
}

func docker_timeout_worker_fn(arg : *void) : *void {
    var cap = arg as *mut docker_worker_captured
    var result = run_command(cap.docker_cmd.to_view())
    cap.promise.set(result)
    return null
}

public func run_docker(container_name: &std.string, host_dir: &std.string) : ExecResult {

    var docker_cmd = std::string()
    // Use conservative flags (see my previous message). You can tweak memory/cpus.
    docker_cmd.append_view(std::string_view("docker run --rm --name "))
    docker_cmd.append_string(container_name)
    docker_cmd.append_view(std::string_view(" --workdir /work --network none --user 1000:1000 --cap-drop ALL"))
    docker_cmd.append_view(std::string_view(" --security-opt no-new-privileges")); // no new privs
    // resource limits
    docker_cmd.append_view(std::string_view(" --pids-limit=32 --memory=256m --memory-swap=512m --cpus=0.25 --ulimit core=0"));
    // make root filesystem read-only (only /work will be writable via a volume/tmpfs)
    docker_cmd.append_view(std::string_view(" --read-only"));
    docker_cmd.append_view(std::string_view(" --tmpfs /tmp:rw,mode=1777 -e TMPDIR=/work"));
    // mount the host dir
    // NOTE: quoting is important: we put the host_dir in double quotes
    docker_cmd.append_view(std::string_view(" -v \""))
    docker_cmd.append_string(host_dir)
    docker_cmd.append_view(std::string_view(":/work:rw\" "))
    docker_cmd.append_view(std::string_view("chemicallang/chemical:v0.0.26-ubuntu sh /work/run_compile.sh"))

    // run the docker command using your run_command helper (captures combined stdout+stderr)
    return run_command(docker_cmd.to_view())

}

public func run_docker_with_timeout(container_name: &std.string, host_dir: &std.string, timeout_ms: ulong) : ExecResult {
    var res_promise = malloc(sizeof(std.concurrent.Promise<ExecResult>)) as *mut std.concurrent.Promise<ExecResult>;
    new(res_promise) std.concurrent.Promise<ExecResult>();

    // Build docker run command
    var docker_cmd = std.string();
   // Use conservative flags (see my previous message). You can tweak memory/cpus.
   docker_cmd.append_view(std::string_view("docker run --rm --name "))
   docker_cmd.append_string(container_name)
   docker_cmd.append_view(std::string_view(" --workdir /work --network none --user 1000:1000 --cap-drop ALL"))
   docker_cmd.append_view(std::string_view(" --security-opt no-new-privileges")); // no new privs
   // resource limits
   docker_cmd.append_view(std::string_view(" --pids-limit=32 --memory=256m --memory-swap=512m --cpus=0.25 --ulimit core=0"));
   // make root filesystem read-only (only /work will be writable via a volume/tmpfs)
   docker_cmd.append_view(std::string_view(" --read-only"));
   docker_cmd.append_view(std::string_view(" --tmpfs /tmp:rw,mode=1777 -e TMPDIR=/work"));
   // mount the host dir
   // NOTE: quoting is important: we put the host_dir in double quotes
   docker_cmd.append_view(std::string_view(" -v \""))
   docker_cmd.append_string(host_dir)
   docker_cmd.append_view(std::string_view(":/work:rw\" "))
   docker_cmd.append_view(std::string_view("chemicallang/chemical:v0.0.26-ubuntu sh /work/run_compile.sh"))

    var cap = docker_worker_captured {
        docker_cmd : &docker_cmd,
        promise : res_promise
    }

    // Spawn thread
    var worker_thread = std.concurrent.spawn(docker_timeout_worker_fn, &mut cap as *mut void);

    // Timeout monitoring loop
    var elapsed: ulong = 0;
    var interval: ulong = 50; // check every 50ms
    var finished: bool = false;

    while(elapsed < timeout_ms) {
        std.concurrent.sleep_ms(interval);
        elapsed += interval;
        if(res_promise.ready) {
            finished = true;
            break;
        }
    }

    if(!finished) {
        // Timeout exceeded -> forcibly kill container
        var kill_cmd = std.string();
        kill_cmd.append_view(std.string_view("docker kill "));
        kill_cmd.append_string(container_name);
        kill_cmd.append_view(std.string_view(" 2>/dev/null"));
        run_command(kill_cmd.to_view());
    }

    // Wait for worker thread to finish to safely capture output
    worker_thread.join()

    // Get the result from promise (partial output if killed)
    var result: ExecResult;
    if(res_promise.ready) {
        result = std::replace(res_promise.val, ExecResult());
    } else {
        // Timeout case: create dummy result
        result = ExecResult();
        result.status = -1;
        result.output = std.string("Process timed out");
    }

    // Clean up promise
    delete res_promise;
    return result;
}


func compile_files_in_docker(settings : &CompileSettings, outputType : OutputType, files : &mut std::vector<std::pair<std::string, std::string>>) : DockerCompilationResult {
    // generate safe random id (as you already do)
    var temp : [13]char
    var r1 = generate_random_32bit()
    var r2 = generate_random_32bit()
    base64_encode_32bit(r1, &mut temp[0])
    base64_encode_32bit(r2, &mut temp[6])
    temp[12] = '\0'
    var dir_name = std::string_view(&temp[0], 12)

    var host_dir = std::string()

    if(def.windows || def.debug) {
        host_dir.append_view(std::string_view("./play-"))
    } else {
        host_dir.append_view(std::string_view("/home/playground/app/play-"))
    }

    host_dir.append_view(dir_name)

    var created = fs::create_dir(host_dir.data())
    if (created is std.Result.Err) {
        var Err(error) = created else unreachable
        var msg = error.message()
        printf("couldn't create workspace directory at %s because %s\n", host_dir.data(), msg.data());
        var res = DockerCompilationResult()
        res.status = -1
        res.error_msg = "couldn't create workspace directory"
        return res
    }

    // set the permissions
    var perm_res = fs::set_permissions(host_dir.data(), 0o755);
    if (perm_res is std.Result.Err) {
        printf("failed setting permissions on %s\n", host_dir.data());
        // cleanup and return error
        fs::remove_dir_all_recursive(host_dir.data());
        var res = DockerCompilationResult()
        res.status = -1
        res.error_msg = "couldn't set permissions on host directory"
        return res
    }

    // write each file into host_dir; validate file names
    while (!files.empty()) {
        var file = files.take_last()
        if (!is_valid_filename(file.first.to_view())) {
            var res = DockerCompilationResult()
            res.status = -1
            res.error_msg = "invalid file name"
            // cleanup
            fs::remove_dir_all_recursive(host_dir.data())
            return res
        }
        if (file.second.size() > 5000) {
            var res = DockerCompilationResult()
            res.status = -1
            res.error_msg = "file too large"
            fs::remove_dir_all_recursive(host_dir.data())
            return res
        }
        var path = std::string()
        // normalize path join with forward slash inside workspace
        path.append_string(host_dir)
        // ensure backslash on Windows and forward slash on POSIX inside host path is OK; Docker will map host path
        if (path.size() > 0 && path.get(path.size() - 1) != '/' && path.get(path.size() - 1) != '\\') {
            path.append_view(std::string_view("/"))
        }
        path.append_string(file.first)
        var written = fs::write_text_file(path.data(), file.second.data() as *u8, file.second.size())
        if (written is std.Result.Err) {
            var Err(err) = written else unreachable;
            var msg = err.message()
            printf("failed writing text file to path %s because %s\n", path.data(), msg.data());
            var res = DockerCompilationResult()
            res.status = -1
            res.error_msg = "couldn't write file in workspace"
            fs::remove_dir_all_recursive(host_dir.data())
            return res
        }
        var perm = fs::set_permissions(path.data(), 0o755)
        if(perm is std.Result.Err) {
            var Err(err) = perm else unreachable;
            var msg = err.message()
            printf("failed to set permissions on path %s because %s\n", path.data(), msg.data());
        }
    }

    // // prepare the command you already create in your original code (cmake/Compiler invocation).
    // var command = std::vector<std::string>()
    // // example: you previously did command.push("cmake-build-debugubuntu/Compiler") etc
    // // reproduce that here:
    // var modFilePath = std::string()
    // // modFilePath.append_string(host_dir)
    // modFilePath.append_view(std::string_view("chemical.mod"))
    // command.push(std::string("chemical"))
    // command.push(modFilePath)
    // command.push(std::string("--no-cache"))
    // command.push(std::string("-o"))
    // var outputFilePath = std::string()
    // // outputFilePath.append_string(host_dir)
    // outputFilePath.append_view(std::string_view("build.exe"))
    // command.push(outputFilePath.copy())
    // if (outputType == OutputType.CTranslation) {
    //     command.push(std::string("-jt"))
    //     command.push(std::string("2c"))
    // } else if(outputType == OutputType.LLVMIR) {
    //     command.push(std::string("-jt"))
    //     command.push(std::string("inter"))
    //     command.push(std::string("-out-ll-all"))
    // } else {
    //     command.push(std::string("&&"))
    //     command.push(outputFilePath.copy())
    // }

    var outputFilePath = std::string_view("build.exe")

    // write entrypoint script into host_dir
    var wr = write_entrypoint_script_new(settings, outputType, host_dir.copy())
    if (wr is std.Result.Err) {
        var res = DockerCompilationResult()
        res.status = -1
        res.error_msg = "couldn't write entrypoint script"
        fs::remove_dir_all_recursive(host_dir.data())
        return res
    }

    if(!def.windows) {
        const esc = shell_escape_single_quotes(host_dir.copy());

        // 1) clear any ACLs recursively (harmless if none)
        var cmd_clear_acl = std::string();
        cmd_clear_acl.append_view(std::string_view("setfacl -bR '"));
        cmd_clear_acl.append_string(esc);
        cmd_clear_acl.append_view(std::string_view("' 2>/dev/null || true"));
        var rc1 = system(cmd_clear_acl.data());
        if (rc1 != 0) {
            printf("warning: setfacl returned %d (ignored)\n", rc1);
        }

        // 2) set sane unix permissions: dirs get +x (X), files get rw for owner/group, r for others
        var cmd_chmod = std::string();
        cmd_chmod.append_view(std::string_view("chmod -R u=rwX,g=rwX,o=rx '"));
        cmd_chmod.append_string(esc);
        cmd_chmod.append_view(std::string_view("' 2>/dev/null || true"));
        var rc2 = system(cmd_chmod.data());
        if (rc2 != 0) {
            printf("warning: chmod returned %d (ignored)\n", rc2);
        }

        // 3) chown everything to the unprivileged container user (UID 1000) so builds can write
        var cmd_chown = std::string();
        cmd_chown.append_view(std::string_view("chown -R 1000:1000 '"));
        cmd_chown.append_string(esc);
        cmd_chown.append_view(std::string_view("' 2>/dev/null || true"));
        var rc3 = system(cmd_chown.data());
        if (rc3 != 0) {
            printf("warning: chown returned %d (ignored)\n", rc3);
        }
    }

    // Build docker run CLI string.
    // We mount host_dir -> /work inside container and run "sh /work/run_compile.sh"
    var container_name = std::string()
    container_name.append_view(std::string_view("chemical-play-"))
    container_name.append_view(dir_name)

    // run the docker command using your run_command helper (captures combined stdout+stderr)
    var procRes = run_docker_with_timeout(container_name, host_dir, 10u * 1000u)
    // procRes.status is exit code of docker run (if docker CLI succeeded it will be the exit code of the process inside container).
    // procRes.output is combined stdout+stderr from docker run

    // read the expected output file from host_dir
    var finalOutPath = std::string()
    if (outputType == OutputType.CTranslation) {
        finalOutPath.append_string(host_dir)
        finalOutPath.append('/');
        finalOutPath.append_view(outputFilePath)
    } else if(outputType == OutputType.LLVMIR) {
        finalOutPath.append_string(host_dir)
        finalOutPath.append_view(std::string_view("/build/main/llvm_ir.ll"))
    } else if(outputType == OutputType.AssemblyOutput) {
        finalOutPath.append_string(host_dir)
        finalOutPath.append_view(std::string_view("/build/main/mod_asm.s"))
    } else {
        // keep final output path empty, as no file to read
    }

    var read_res = fs::read_entire_file(finalOutPath.data())
    var out_file_content = std::string()
    if(finalOutPath.empty()) {
        out_file_content.append_string(procRes.output)
    } else {
        if (read_res is std.Result.Err) {
            // Could not read output — return whatever logs we have
            var res = DockerCompilationResult()
            res.status = procRes.status
            res.stdout_and_stderr = std::replace(procRes.output, std::string())
            res.output = std::string() // empty
            res.error_msg = "couldn't read output file"
            printf("couldn't read the file at path %s\n", finalOutPath.data());
            // cleanup
            var rem_res = fs::remove_dir_all_recursive(host_dir.data())
            if (rem_res is std.Result.Err) {
                // print removal error but continue
                var Err(err) = rem_res else unreachable
                var msg = err.message()
                printf("error removing directory at '%s' with message '%s'\n", host_dir.data(), msg.data());
            }
            return res
        } else {
            var Ok(value) = read_res else unreachable
            out_file_content.append_view(std::string_view(value.data() as *char, value.size()))
        }
    }

    // cleanup host_dir
    var rem_res2 = fs::remove_dir_all_recursive(host_dir.data())
    if (rem_res2 is std.Result.Err) {
        var Err(err) = rem_res2 else unreachable
        var msg = err.message()
        printf("error removing directory at '%s' with message '%s'\n", host_dir.data(), msg.data());
    }

    // return success
    var cres = DockerCompilationResult()
    cres.status = procRes.status
    cres.stdout_and_stderr = std::replace(procRes.output, std::string())
    cres.output = out_file_content
    return cres
}
