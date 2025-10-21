// minimal externs
if (def.windows) {
    // Win32 kernel32 / stdio functions (ANSI variants used in the example)
    @extern @dllimport @stdcall public func CreatePipe(readPipe : *mut HANDLE, writePipe : *mut HANDLE, lpPipeAttributes : *mut SECURITY_ATTRIBUTES, nSize : DWORD) : BOOL;
    @extern @dllimport @stdcall public func SetHandleInformation(hObject : HANDLE, dwMask : DWORD, dwFlags : DWORD) : BOOL;
    // @extern @dllimport @stdcall public func CreateProcessA(lpApplicationName : *char, lpCommandLine : *mut char, lpProcessAttributes : *mut void, lpThreadAttributes : *mut void, bInheritHandles : BOOL, dwCreationFlags : DWORD, lpEnvironment : *mut void, lpCurrentDirectory : *char, lpStartupInfo : *mut STARTUPINFOA, lpProcessInformation : *mut PROCESS_INFORMATION) : BOOL;
    // @extern @dllimport @stdcall public func CloseHandle(hObject : HANDLE) : BOOL;
    @extern @dllimport @stdcall public func GetLastError() : DWORD;
    @extern @dllimport @stdcall public func WaitForSingleObject(hHandle : HANDLE, dwMilliseconds : DWORD) : DWORD;
    // @extern @dllimport @stdcall public func GetExitCodeProcess(hProcess : HANDLE, lpExitCode : *mut DWORD) : BOOL;
    // @extern @dllimport @stdcall public func ReadFile(hFile : HANDLE, lpBuffer : *mut void, nNumberOfBytesToRead : DWORD, lpNumberOfBytesRead : *mut DWORD, lpOverlapped : *mut void) : BOOL;
    @extern @dllimport @stdcall public func GetStdHandle(nStdHandle : DWORD) : HANDLE;

    // used with STARTUPINFO.dwFlags
    const STARTF_USESTDHANDLES : DWORD = 0x00000100u;

    // used with SetHandleInformation
    const HANDLE_FLAG_INHERIT : DWORD = 0x00000001u;

    // values for GetStdHandle (these are negative in the Win32 API).
    // You can pass them directly, or cast to DWORD if your bindings require it.
    // STD_INPUT_HANDLE  = -10
    // STD_OUTPUT_HANDLE = -11
    // STD_ERROR_HANDLE  = -12
    const STD_INPUT_HANDLE  : int = -10;
    const STD_OUTPUT_HANDLE : int = -11;
    const STD_ERROR_HANDLE  : int = -12;

    // used with WaitForSingleObject
    const INFINITE : DWORD = 0xFFFFFFFFu;

} else {
    // POSIX functions
    @extern public func pipe(fds : *mut int) : int;
    @extern public func fork() : pid_t;
    @extern public func dup2(oldfd : int, newfd : int) : int;
    @extern public func close(fd : int) : int;
    @extern public func execvp(file : *char, argv : *mut *char) : int;
    @extern public func _exit(status : int) : void;   // use _exit in child after exec failure
    @extern public func read(fd : int, buf : *mut void, count : size_t) : ssize_t;
    @extern public func waitpid(pid : pid_t, status : *mut int, options : int) : pid_t;

    // errno helpers (optional, used in some error paths)
    // @extern public func strerror(errnum : int) : *char;

    // POSIX: file descriptor numbers
    const STDIN_FILENO  : int = 0;
    const STDOUT_FILENO : int = 1;
    const STDERR_FILENO : int = 2;


    public func wifexited(status : int) : bool {
        // true if child terminated normally via exit()
        return ((status & 0xff) == 0);
    }

    public func wexitstatus(status : int) : int {
        // exit code passed to exit() or returned by main(); valid only if wifexited(status) true
        return ((status >> 8) & 0xff);
    }

    public func wifsignaled(status : int) : bool {
        // true if child was terminated by a signal
        // many platforms encode this as: low 7 bits = signal number (non-zero) and low 8 bits != 0x7f (stopped)
        var low = status & 0xff;
        return (low != 0 && low != 0x7f);
    }

    public func wtermsig(status : int) : int {
        // the signal number that caused termination; valid only if wifsignaled(status) true
        return (status & 0x7f);
    }

    public func wcoredump(status : int) : bool {
        // core-dump flag (non-portable on some systems but commonly bit 7 is core bit)
        return ((status & 0x80) != 0);
    }

    public func wifstopped(status : int) : bool {
        // true if child is currently stopped (by SIGSTOP, SIGTSTP, etc.)
        return ((status & 0xff) == 0x7f);
    }

    public func wstopsig(status : int) : int {
        // stop signal number, valid only if wifstopped(status) true
        return ((status >> 8) & 0xff);
    }

}


public struct ProcResult {
    var exit_code : int
    var output : std::string
    var success : bool
}

// Small helper: quote an arg for CreateProcess commandline (very small, handles spaces and quotes)
func _quote_arg_for_cmd(a : &std::string) : std::string {
    var out = std::string()
    var needs = false
    for (var i = 0; i < a.size(); i = i + 1) {
        var ch = a.data()[i]
        if (ch == ' ' || ch == '\t' || ch == '"' ) { needs = true; break; }
    }
    if (!needs) { out.append_view(std::string_view(a)); return out; }
    out.append('"')
    for (var i = 0; i < a.size(); i = i + 1) {
        var ch = a.data()[i]
        if (ch == '"') {
            out.append_view(std::string_view("\\\"")) // escape quote
        } else {
            out.append_with_len(&a.data()[i], 1)
        }
    }
    out.append('"')
    return out
}

public func launch_exe(args : &std::vector<std::string>) : ProcResult {
    var result = ProcResult()
    result.exit_code = -1
    result.output = std::string()
    result.success = false

    if (args.empty()) {
        result.output = std::string("no arguments")
        return result
    }

    comptime if (def.windows) {
        // ------- Windows: CreateProcessA with redirected stdout+stderr -------
        var sa : SECURITY_ATTRIBUTES
        sa.nLength = sizeof(sa)
        sa.lpSecurityDescriptor = null
        sa.bInheritHandle = true

        var out_read : HANDLE = null
        var out_write : HANDLE = null
        if (!CreatePipe(&mut out_read, &mut out_write, &mut sa, 0)) {
            result.output = std::string("CreatePipe failed")
            return result
        }
        // parent shouldn't inherit the read handle
        SetHandleInformation(out_read, HANDLE_FLAG_INHERIT, 0)

        var si : STARTUPINFOA
        var pi : PROCESS_INFORMATION
        ZeroMemory(&mut si, sizeof(si))
        si.cb = sizeof(si)
        si.dwFlags = STARTF_USESTDHANDLES
        si.hStdOutput = out_write
        si.hStdError  = out_write
        si.hStdInput  = GetStdHandle(STD_INPUT_HANDLE as DWORD) // keep parent's stdin

        ZeroMemory(&mut pi, sizeof(pi))

        // Build mutable commandline: first arg is program, follow with quoted args
        var cmd : std::string = std::string()
        // first arg (executable) - quote if needed
        cmd.append_string(_quote_arg_for_cmd(*args.get_ptr(0)))
        for (var i = 1; i < args.size(); i++) {
            cmd.append(' ')
            var q = _quote_arg_for_cmd(*args.get_ptr(i as size_t))
            cmd.append_string(q)
        }

        // CreateProcessA wants a mutable char buffer
        var ok = CreateProcessA(
            null,
            cmd.mutable_data(),
            null,
            null,
            true, // inherit handles (we pass the write handle)
            0,
            null,
            null,
            &mut si,
            &mut pi
        )

        // close local write handle in parent after CreateProcess (child has its own)
        CloseHandle(out_write)
        out_write = null

        if (!ok) {
            var e = GetLastError()
            var msg = std::string()
            // minimal error message
            msg.append_view(std::string_view("CreateProcessA failed: "))
            // convert error number to decimal text quickly
            var buf : [64]char
            memset(&mut buf[0], 0, sizeof(buf))
            sprintf(&mut buf[0], "%lu", e as ulong)
            msg.append_with_len((&buf[0]) as *char, strlen(&mut buf[0]))
            result.output = msg
            // ensure handles closed
            if (out_read != null) { CloseHandle(out_read) }
            return result
        }

        // read from pipe until EOF
        var buf : [4096]u8
        memset(&mut buf[0], 0, sizeof(buf))
        while (true) {
            var read_bytes : DWORD = 0
            var okr = ReadFile(out_read, &mut buf[0] as *mut void, 4096 as DWORD, &mut read_bytes, null)
            if (!okr || read_bytes == 0) { break; }
            result.output.append_with_len((&buf[0]) as *char, read_bytes as size_t)
        }

        // wait for process
        WaitForSingleObject(pi.hProcess, INFINITE as DWORD)

        var exitCode : DWORD = 0
        if (GetExitCodeProcess(pi.hProcess, &mut exitCode)) {
            result.exit_code = exitCode as int
            result.success = true
        } else {
            result.exit_code = -1
            result.success = false
        }

        // cleanup
        CloseHandle(pi.hProcess)
        CloseHandle(pi.hThread)
        if (out_read != null) { CloseHandle(out_read) }

        return result
    } else {
        // ------- POSIX: fork + execvp with a pipe capturing stdout+stderr -------
        var fds : [2]int
        fds[0] = 0
        fds[1] = 0
        if (pipe(&mut fds[0]) != 0) {
            result.output = std::string("pipe failed")
            return result
        }

        var pid : pid_t = fork()
        if (pid < 0) {
            // fork failed
            result.output = std::string("fork failed")
            // close fds
            close(fds[0]); close(fds[1]);
            return result
        }

        if (pid == 0) {
            // child
            // redirect stdout and stderr to write end
            dup2(fds[1], STDOUT_FILENO)
            dup2(fds[1], STDERR_FILENO)
            // close both ends in child (no longer needed)
            close(fds[0])
            close(fds[1])

            // build argv array for execvp (null-terminated)
            var argc = args.size()
            var vec : std::vector<*char> = std::vector<*char>()
            for (var i = 0u; i < argc; i++) {
                vec.push(args.get_ptr(i).data())
            }
            vec.push(null)

            // execvp: argv[0] must be program name or path
            execvp(vec.get(0), (vec.get_ptr(0)) as *mut *char)
            // if exec returns, error
            _exit(127)
        } else {
            // parent
            // close write end, read from read end
            close(fds[1])
            var buf : [4096]u8
            memset(&mut buf[0], 0, sizeof(buf))
            while (true) {
                var n = read(fds[0], &mut buf[0] as *mut void, 4096 as size_t)
                if (n <= 0) { break; }
                result.output.append_with_len((&buf[0]) as *char, n as size_t)
            }
            close(fds[0])

            // wait for child
            var status : int = 0
            if (waitpid(pid, &mut status, 0) < 0) {
                result.output.append_view(std::string_view("waitpid failed"))
                result.exit_code = -1
                return result
            }

            if (wifexited(status)) {
                result.exit_code = wexitstatus(status)
                result.success = true
            } else if (wifsignaled(status)) {
                result.exit_code = -1
                result.success = false
            } else {
                result.exit_code = -1
                result.success = false
            }
            return result
        }
    }
}