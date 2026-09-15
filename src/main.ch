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
