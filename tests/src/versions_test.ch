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
    if (V_DEFAULT != V_511) { env.error("default version must be the newest (V_511)") }
}

@test
public func test_versions_descending(env : &mut TestEnv) {
    if (!(V_511 > V_510 && V_510 > V_59)) { env.error("supported versions must be strictly descending") }
    if (SUPPORTED_VERSIONS[0] != V_511 || SUPPORTED_VERSIONS[1] != V_510 || SUPPORTED_VERSIONS[2] != V_59) {
        env.error("SUPPORTED_VERSIONS must list versions newest-first")
    }
}

@test
public func test_version_from_hash_roundtrip(env : &mut TestEnv) {
    // the hashes are computed from the same strings the compiler switches on
    if (version_from_hash(V511_HASH) != V_511) { env.error("V511_HASH must map back to V_511") }
    if (version_from_hash(V510_HASH) != V_510) { env.error("V510_HASH must map back to V_510") }
    if (version_from_hash(V59_HASH) != V_59) { env.error("V59_HASH must map back to V_59") }
}

@test
public func test_version_from_hash_unknown_falls_back_to_default(env : &mut TestEnv) {
    var bogus = comptime_fnv1_hash("not-a-version")
    if (version_from_hash(bogus) != V_DEFAULT) { env.error("unknown hash must fall back to V_DEFAULT") }
}

@test
public func test_docker_tag_suffix(env : &mut TestEnv) {
    var tag511 = docker_tag_suffix(V_511)
    if (!tag511.equals(std::string_view("v0.5.11-ubuntu"))) { env.error("wrong tag for V_511") }
    var tag510 = docker_tag_suffix(V_510)
    if (!tag510.equals(std::string_view("v0.5.10-ubuntu"))) { env.error("wrong tag for V_510") }
    var tag59 = docker_tag_suffix(V_59)
    if (!tag59.equals(std::string_view("v0.5.9-ubuntu"))) { env.error("wrong tag for V_59") }
}

@test
public func test_docker_tag_suffix_fallback(env : &mut TestEnv) {
    var tag = docker_tag_suffix(1)
    if (!tag.equals(std::string_view("v0.5.9-ubuntu"))) { env.error("unknown version must fall back to oldest tag") }
}

@test
public func test_version_label(env : &mut TestEnv) {
    var l511 = version_label(V_511)
    if (!l511.equals(std::string_view("v0.5.11"))) { env.error("wrong label for V_511") }
    var l510 = version_label(V_510)
    if (!l510.equals(std::string_view("v0.5.10"))) { env.error("wrong label for V_510") }
    var l59 = version_label(V_59)
    if (!l59.equals(std::string_view("v0.5.9"))) { env.error("wrong label for V_59") }
}

@test
public func test_version_options_html(env : &mut TestEnv) {
    var html = version_options_html()
    var view = html.to_view()
    // every supported version appears once as an <option>
    if (view.find(std::string_view("<option value=\"511\" selected>")) == std::NPOS) { env.error("default version must be selected in options html") }
    if (view.find(std::string_view("<option value=\"510\">")) == std::NPOS) { env.error("V_510 option missing") }
    if (view.find(std::string_view("<option value=\"59\">")) == std::NPOS) { env.error("V_59 option missing") }
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
