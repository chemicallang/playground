// Supported compiler version constants — single source of truth
// Keep only the latest 3 versions; update when cutting a new release

public comptime const V_511 : int = 511;
public comptime const V_510 : int = 510;
public comptime const V_59 : int = 59;
public comptime const V_DEFAULT : int = V_511;

public const SUPPORTED_COUNT : int = 3;
public const SUPPORTED_VERSIONS : [3]int = [V_511, V_510, V_59];

// FNV1a hashes for string-based version lookup (used in main.ch switch cases)
public const V511_HASH : uint = comptime_fnv1_hash("511");
public const V510_HASH : uint = comptime_fnv1_hash("510");
public const V59_HASH : uint = comptime_fnv1_hash("59");

// Map an FNV1a hash to a version number
public func version_from_hash(hash : uint) : int {
    if (hash == V511_HASH) { return V_511 }
    else if (hash == V510_HASH) { return V_510 }
    else if (hash == V59_HASH) { return V_59 }
    else { return V_DEFAULT }
}

// Docker image tag suffix from version number
public func docker_tag_suffix(v : int) : std::string_view {
    if (v == V_511) { return std::string_view("v0.5.11-ubuntu") }
    else if (v == V_510) { return std::string_view("v0.5.10-ubuntu") }
    else { return std::string_view("v0.5.9-ubuntu") }
}

// Display label for version dropdown
public func version_label(v : int) : std::string_view {
    if (v == V_511) { return std::string_view("v0.5.11") }
    else if (v == V_510) { return std::string_view("v0.5.10") }
    else { return std::string_view("v0.5.9") }
}

// Generate version <option> HTML for the settings dropdown
public func version_options_html() : std::string {
    var out = std::string()
    for (var i = 0u; i < SUPPORTED_COUNT; i++) {
        var v = SUPPORTED_VERSIONS[i]
        if (i > 0u) { out.append_view(std::string_view("\n")) }
        out.append_view(std::string_view("                      <option value=\""))
        out.append_integer(v)
        if (v == V_DEFAULT) {
            out.append_view(std::string_view("\" selected>"))
        } else {
            out.append_view(std::string_view("\">"))
        }
        out.append_view(version_label(v))
        out.append_view(std::string_view("</option>"))
    }
    return out
}
