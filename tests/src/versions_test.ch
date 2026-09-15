// Tests for src/versions.ch — the single source of truth for supported
// compiler versions, docker tags, labels, and dropdown option HTML.
using std::string
using std::string_view

@test
public func test_supported_versions_count(env : &mut TestEnv) {
    if (SUPPORTED_COUNT != 3) { env.error("expected exactly 3 supported versions") }
}

@test
public func test_default_is_newest(env : &mut TestEnv) {
    if (V_DEFAULT != V_55) { env.error("default version must be the newest (V_55)") }
}

@test
public func test_versions_descending(env : &mut TestEnv) {
    if (!(V_55 > V_54 && V_54 > V_53)) { env.error("supported versions must be strictly descending") }
    if (SUPPORTED_VERSIONS[0] != V_55 || SUPPORTED_VERSIONS[1] != V_54 || SUPPORTED_VERSIONS[2] != V_53) {
        env.error("SUPPORTED_VERSIONS must list versions newest-first")
    }
}

@test
public func test_version_from_hash_roundtrip(env : &mut TestEnv) {
    // the hashes are computed from the same strings the compiler switches on
    if (version_from_hash(V55_HASH) != V_55) { env.error("V55_HASH must map back to V_55") }
    if (version_from_hash(V54_HASH) != V_54) { env.error("V54_HASH must map back to V_54") }
    if (version_from_hash(V53_HASH) != V_53) { env.error("V53_HASH must map back to V_53") }
}

@test
public func test_version_from_hash_unknown_falls_back_to_default(env : &mut TestEnv) {
    var bogus = comptime_fnv1_hash("not-a-version")
    if (version_from_hash(bogus) != V_DEFAULT) { env.error("unknown hash must fall back to V_DEFAULT") }
}

@test
public func test_docker_tag_suffix(env : &mut TestEnv) {
    var tag55 = docker_tag_suffix(V_55)
    if (!tag55.equals(std::string_view("v0.5.5-ubuntu"))) { env.error("wrong tag for V_55") }
    var tag54 = docker_tag_suffix(V_54)
    if (!tag54.equals(std::string_view("v0.5.4-ubuntu"))) { env.error("wrong tag for V_54") }
    var tag53 = docker_tag_suffix(V_53)
    if (!tag53.equals(std::string_view("v0.5.3-ubuntu"))) { env.error("wrong tag for V_53") }
}

@test
public func test_docker_tag_suffix_fallback(env : &mut TestEnv) {
    var tag = docker_tag_suffix(1)
    if (!tag.equals(std::string_view("v0.5.3-ubuntu"))) { env.error("unknown version must fall back to oldest tag") }
}

@test
public func test_version_label(env : &mut TestEnv) {
    var l55 = version_label(V_55)
    if (!l55.equals(std::string_view("v0.5.5"))) { env.error("wrong label for V_55") }
    var l54 = version_label(V_54)
    if (!l54.equals(std::string_view("v0.5.4"))) { env.error("wrong label for V_54") }
    var l53 = version_label(V_53)
    if (!l53.equals(std::string_view("v0.5.3"))) { env.error("wrong label for V_53") }
}

@test
public func test_version_options_html(env : &mut TestEnv) {
    var html = version_options_html()
    var view = html.to_view()
    // every supported version appears once as an <option>
    if (view.find(std::string_view("<option value=\"55\" selected>")) == std::NPOS) { env.error("default version must be selected in options html") }
    if (view.find(std::string_view("<option value=\"54\">")) == std::NPOS) { env.error("V_54 option missing") }
    if (view.find(std::string_view("<option value=\"53\">")) == std::NPOS) { env.error("V_53 option missing") }
    if (view.find(std::string_view("</option>")) == std::NPOS) { env.error("options html missing closing tags") }
}

@test
public func test_version_options_html_only_default_selected(env : &mut TestEnv) {
    var html = version_options_html()
    var view = html.to_view()
    // 'selected' must appear exactly once: only the default option carries it
    var first = view.find(std::string_view("selected"))
    if (first == std::NPOS) { env.error("default version must be marked selected") }
    var rest = view.skip(first + 8)
    if (rest.find(std::string_view("selected")) != std::NPOS) { env.error("only the default version may carry the selected attribute") }
}
