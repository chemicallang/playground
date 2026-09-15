// Tests for src/validation.ch — filename validation protecting the Docker
// workspace from path traversal, absolute paths, and junk characters.
using std::string
using std::string_view

// NOTE: is_valid_filename is internal (no `public`), but Chemical compiles the
// whole application as one unit, so tests can call it directly.

@test
public func test_valid_simple_name(env : &mut TestEnv) {
    if (!is_valid_filename("main.ch")) { env.error("simple file name should be valid") }
}

@test
public func test_valid_nested_path(env : &mut TestEnv) {
    if (!is_valid_filename("src/lib/util.ch")) { env.error("nested path should be valid") }
}

@test
public func test_valid_name_with_dots_underscore_dash(env : &mut TestEnv) {
    if (!is_valid_filename("my-file_v2.final.ch")) { env.error("name with . _ - should be valid") }
}

@test
public func test_empty_name_rejected(env : &mut TestEnv) {
    if (is_valid_filename("")) { env.error("empty name must be rejected") }
}

@test
public func test_absolute_path_rejected(env : &mut TestEnv) {
    if (is_valid_filename("/etc/passwd")) { env.error("absolute unix path must be rejected") }
}

@test
public func test_backslash_root_rejected(env : &mut TestEnv) {
    if (is_valid_filename("\\windows\\file.ch")) { env.error("backslash-rooted path must be rejected") }
}

@test
public func test_windows_drive_letter_rejected(env : &mut TestEnv) {
    if (is_valid_filename("C:evil.ch")) { env.error("drive-letter form must be rejected") }
    if (is_valid_filename("c:evil.ch")) { env.error("lowercase drive-letter form must be rejected") }
}

@test
public func test_parent_traversal_rejected(env : &mut TestEnv) {
    if (is_valid_filename("../secret")) { env.error("leading .. segment must be rejected") }
}

@test
public func test_embedded_parent_traversal_rejected(env : &mut TestEnv) {
    if (is_valid_filename("src/../../secret")) { env.error("embedded .. segment must be rejected") }
}

@test
public func test_dots_in_middle_of_name_allowed(env : &mut TestEnv) {
    // "a..b" is fine: ".." only matters when surrounded by separators/boundaries
    if (!is_valid_filename("a..b.ch")) { env.error("dots not forming a .. segment should be allowed") }
}

@test
public func test_single_dot_segment_allowed(env : &mut TestEnv) {
    if (!is_valid_filename("./main.ch")) { env.error("single dot segment should be allowed") }
}

@test
public func test_disallowed_characters_rejected(env : &mut TestEnv) {
    if (is_valid_filename("file name.ch")) { env.error("space must be rejected") }
    if (is_valid_filename("file;rm.ch")) { env.error("semicolon must be rejected") }
    if (is_valid_filename("file$(id).ch")) { env.error("shell substitution chars must be rejected") }
}

@test
public func test_trailing_parent_segment_rejected(env : &mut TestEnv) {
    if (is_valid_filename("src/..")) { env.error("trailing .. segment must be rejected") }
}
