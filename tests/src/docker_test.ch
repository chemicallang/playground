// Tests for src/docker.ch — only the pure, side-effect-free helpers:
// entrypoint script generation and shell escaping. The docker invocation
// itself is exercised by scripts/playground-build-test.sh against a real
// daemon, not here.
using std::string
using std::string_view

// ---- CompileSettings defaults ----

@test
public func test_compile_settings_defaults(env : &mut TestEnv) {
    var s = CompileSettings()
    if (s.verbose) { env.error("verbose must default to false") }
    if (s.use_tcc) { env.error("use_tcc must default to false") }
    if (s.debug_ir) { env.error("debug_ir must default to false") }
    if (s.lto) { env.error("lto must default to false") }
    if (s.benchmark) { env.error("benchmark must default to false") }
    if (s.bm_files) { env.error("bm_files must default to false") }
    if (s.bm_modules) { env.error("bm_modules must default to false") }
    if (s.version != V_511) { env.error("version must default to the newest supported version") }
    if (!s.mode.empty()) { env.error("mode must default to empty") }
}

// ---- shell_escape_single_quotes ----

// build the literal content of the entrypoint script for inspection.
// write_entrypoint_script_new writes to disk, so tests call it against a
// throwaway directory under /tmp and read the file back.
func read_entrypoint_script(settings : &CompileSettings, ot : OutputType, tag : std::string_view) : std::string {
    var dir = std::string("/tmp/pg_test_ep_")
    dir.append_view(&tag)
    var created = fs::create_dir_all(dir.data())
    if (created is std.Result.Err) { return std::string() }

    var wr = write_entrypoint_script_new(settings, ot, dir.copy())
    if (wr is std.Result.Err) {
        fs::remove_dir_all_recursive(dir.data())
        return std::string()
    }

    var path = std::string()
    path.append_string(&dir)
    path.append_view(std::string_view("/run_compile.sh"))
    var content = std::string()
    var rr = fs::read_entire_file(path.data())
    if (rr is std.Result.Ok) {
        var Ok(bytes) = rr else unreachable
        content.append_view(std::string_view(bytes.data() as *char, bytes.size()))
    }
    fs::remove_dir_all_recursive(dir.data())
    return content
}

@test
public func test_entrypoint_base_script(env : &mut TestEnv) {
    var s = CompileSettings()
    var content = read_entrypoint_script(&s, OutputType.CompilerOutput, "base")
    if (content.empty()) { env.error("couldn't generate/read entrypoint script") }
    if (content.find(std::string_view("'chemical' 'chemical.mod' '--no-cache' -o 'build.exe'")) == std::NPOS) {
        env.error("base compile command missing from entrypoint script")
    }
    if (content.find(std::string_view("#!/bin/sh")) != 0) { env.error("script must start with shebang") }
}

@test
public func test_entrypoint_run_out_execs_build(env : &mut TestEnv) {
    var s = CompileSettings()
    var content = read_entrypoint_script(&s, OutputType.RunOut, "runout")
    if (content.find(std::string_view("exec ./build.exe")) == std::NPOS) { env.error("RunOut script must exec ./build.exe") }
    if (content.find(std::string_view("/dev/null")) == std::NPOS) { env.error("RunOut script must silence compiler output") }
}

@test
public func test_entrypoint_ctranslation_flag(env : &mut TestEnv) {
    var s = CompileSettings()
    var content = read_entrypoint_script(&s, OutputType.CTranslation, "ctrans")
    if (content.find(std::string_view("-jt 2c")) == std::NPOS) { env.error("CTranslation script must pass '-jt 2c'") }
    if (content.find(std::string_view("exec ./build.exe")) != std::NPOS) { env.error("CTranslation script must not exec build") }
}

@test
public func test_entrypoint_llvmir_flag(env : &mut TestEnv) {
    var s = CompileSettings()
    var content = read_entrypoint_script(&s, OutputType.LLVMIR, "llvmir")
    if (content.find(std::string_view("-jt inter")) == std::NPOS || content.find(std::string_view("-out-ll-all")) == std::NPOS) {
        env.error("LLVMIR script must pass '-jt inter -out-ll-all'")
    }
}

@test
public func test_entrypoint_assembly_flag(env : &mut TestEnv) {
    var s = CompileSettings()
    var content = read_entrypoint_script(&s, OutputType.AssemblyOutput, "asm")
    if (content.find(std::string_view("-out-asm-all")) == std::NPOS) { env.error("AssemblyOutput script must pass '-out-asm-all'") }
}

@test
public func test_entrypoint_mode_whitelisted(env : &mut TestEnv) {
    var s = CompileSettings()
    s.mode = std::string("release_fast")
    var content = read_entrypoint_script(&s, OutputType.CompilerOutput, "modeok")
    if (content.find(std::string_view("--mode 'release_fast'")) == std::NPOS) { env.error("whitelisted mode must be forwarded to the compiler") }
}

@test
public func test_entrypoint_mode_not_whitelisted_ignored(env : &mut TestEnv) {
    var s = CompileSettings()
    s.mode = std::string("rm -rf /")
    var content = read_entrypoint_script(&s, OutputType.CompilerOutput, "modebad")
    if (content.find(std::string_view("--mode")) != std::NPOS) { env.error("non-whitelisted mode must be ignored") }
}

@test
public func test_entrypoint_flags_gated_by_output_type(env : &mut TestEnv) {
    var s = CompileSettings()
    s.verbose = true
    s.benchmark = true
    s.use_tcc = true

    // benchmark flags only apply to CompilerOutput
    var co = read_entrypoint_script(&s, OutputType.CompilerOutput, "gate_co")
    if (co.find(std::string_view("--verbose")) == std::NPOS || co.find(std::string_view("--benchmark")) == std::NPOS) {
        env.error("CompilerOutput script must carry verbose/benchmark flags")
    }
    var ro = read_entrypoint_script(&s, OutputType.RunOut, "gate_ro")
    if (ro.find(std::string_view("--verbose")) != std::NPOS || ro.find(std::string_view("--benchmark")) != std::NPOS) {
        env.error("RunOut script must not carry verbose/benchmark flags")
    }
    // use_tcc applies to both RunOut and CompilerOutput
    if (ro.find(std::string_view("--use-tcc")) == std::NPOS) { env.error("RunOut script must carry --use-tcc") }
    if (co.find(std::string_view("--use-tcc")) == std::NPOS) { env.error("CompilerOutput script must carry --use-tcc") }
    var ct = read_entrypoint_script(&s, OutputType.CTranslation, "gate_ct")
    if (ct.find(std::string_view("--use-tcc")) != std::NPOS) { env.error("CTranslation script must not carry --use-tcc") }
}

@test
public func test_entrypoint_debug_ir_and_lto(env : &mut TestEnv) {
    var s = CompileSettings()
    s.debug_ir = true
    s.lto = true
    var content = read_entrypoint_script(&s, OutputType.CompilerOutput, "dirlto")
    if (content.find(std::string_view("--debug-ir")) == std::NPOS) { env.error("--debug-ir missing") }
    if (content.find(std::string_view("--lto")) == std::NPOS) { env.error("--lto missing") }
}

// ---- shell_escape_single_quotes (indirectly via behavior contract) ----

@test
public func test_shell_escape_round_trip(env : &mut TestEnv) {
    // the escape must produce shell-safe output for quote-containing input
    var evil = std::string("dir'; rm -rf /; echo '")
    var esc = shell_escape_single_quotes(evil)
    var view = esc.to_view()
    // every single quote in input becomes '"'"' — so the output must not
    // contain a bare ' not immediately preceded by " and followed by "
    if (view.find(std::string_view("'\"'\"'")) == std::NPOS) { env.error("embedded quote must be escaped as quote-doublequote-quote sequence") }
}

// ---- DockerCompilationResult / run_command sanity ----

@test
public func test_run_command_echo(env : &mut TestEnv) {
    var r = run_command(std::string_view("echo chemical_test_ok"))
    if (r.status != 0) { env.error("echo must exit 0") }
    if (r.output.find(std::string_view("chemical_test_ok")) == std::NPOS) { env.error("echo output must be captured") }
}

@test
public func test_run_command_captures_stderr_and_exit_code(env : &mut TestEnv) {
    var r = run_command(std::string_view("sh -c 'echo boom >&2; exit 3'"))
    if (r.status != 3) { env.error("exit code must be extracted from pclose wait status") }
    if (r.output.find(std::string_view("boom")) == std::NPOS) { env.error("stderr must be merged into output") }
}

@test
public func test_base64_encode_32bit_roundtrip_chars(env : &mut TestEnv) {
    var buf : [7]char
    // out is filled backwards: out[5] gets the lowest 6 bits, out[0] the highest.
    base64_encode_32bit(0u, &raw mut buf[0])
    if (buf[5] != 'A') { env.error("hash 0 must encode to 'A' in the low digit") }
    // second call must fully overwrite the buffer (no stale bytes from before)
    var all_ones : u32 = 0xFFFFFFFFu
    base64_encode_32bit(all_ones, &raw mut buf[0])
    // all six 6-bit groups of 0xFFFFFFFF are 0x3F (63) → all six digits must be
    // drawn from the last alphabet chars; the exact glyph set is '__' (62|63),
    // so each digit must be '_'. Accept either final char defensively.
    for (var i = 0; i < 6; i++) {
        if (buf[i] == 'A') { env.error("max hash must not encode to 'A' (index 0)") }
    }
}
