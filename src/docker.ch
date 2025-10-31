// result returned from compiling in Docker
public struct DockerCompilationResult {
    var status : int = 0              // exit code of compiler inside container (or -1 on internal error)
    var stdout_and_stderr : std::string
    var output : std::string // e.g. llvm_ir.ll or compiled binary (text here)
    var error_msg : *char = null
}

// new: compile settings carried from the UI
public struct CompileSettings {
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

    if(outputType == OutputType.CTranslation) {
        content.append_view(std::string_view(" -jt"))
        content.append_view(std::string_view(" 2c"))
    } else if(outputType == OutputType.LLVMIR) {
        content.append_view(std::string_view(" -jt"))
        content.append_view(std::string_view(" inter"))
        content.append_view(std::string_view(" -out-ll-all"))
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
    // if hosting on POSIX we would chmod +x, but inside container we will invoke "sh /work/run_compile.sh" so executable bit not strictly necessary.
    return std.Result.Ok(UnitTy{})
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
    host_dir.append_view(std::string_view("./play-"))
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
            var res = DockerCompilationResult()
            res.status = -1
            res.error_msg = "couldn't write file in workspace"
            fs::remove_dir_all_recursive(host_dir.data())
            return res
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

    // Build docker run CLI string.
    // We mount host_dir -> /work inside container and run "sh /work/run_compile.sh"
    var container_name = std::string()
    container_name.append_view(std::string_view("chemical-play-"))
    container_name.append_view(dir_name)

    var docker_cmd = std::string()
    // Use conservative flags (see my previous message). You can tweak memory/cpus.
    docker_cmd.append_view(std::string_view("docker run --rm --name "))
    docker_cmd.append_string(container_name)
    docker_cmd.append_view(std::string_view(" --workdir /work --network none --user 1000:1000 --cap-drop ALL"))
    docker_cmd.append_view(std::string_view(" --security-opt no-new-privileges")); // no new privs
    // resource limits
    docker_cmd.append_view(std::string_view(" --pids-limit=128 --memory=256m --memory-swap=256m --cpus=0.5 --ulimit core=0"));
    // make root filesystem read-only (only /work will be writable via a volume/tmpfs)
    docker_cmd.append_view(std::string_view(" --read-only"));
    // mount the host dir
    // NOTE: quoting is important: we put the host_dir in double quotes
    docker_cmd.append_view(std::string_view(" -v \""))
    docker_cmd.append_string(host_dir)
    docker_cmd.append_view(std::string_view(":/work:rw\" "))
    docker_cmd.append_view(std::string_view("chemicallang/chemical:v0.0.25-ubuntu sh /work/run_compile.sh"))

    // run the docker command using your run_command helper (captures combined stdout+stderr)
    var procRes = run_command(docker_cmd.to_view())
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
