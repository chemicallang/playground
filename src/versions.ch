// Supported compiler version constants — single source of truth
// Keep only the latest 3 versions; update when cutting a new release

public comptime const V_55 : int = 55;
public comptime const V_54 : int = 54;
public comptime const V_53 : int = 53;
public comptime const V_DEFAULT : int = V_55;

public const SUPPORTED_COUNT : int = 3;
public const SUPPORTED_VERSIONS : [3]int = [V_55, V_54, V_53];

// FNV1a hashes for string-based version lookup (used in main.ch switch cases)
public const V55_HASH : uint = comptime_fnv1_hash("55");
public const V54_HASH : uint = comptime_fnv1_hash("54");
public const V53_HASH : uint = comptime_fnv1_hash("53");

// Map an FNV1a hash to a version number
public func version_from_hash(hash : uint) : int {
    if (hash == V55_HASH) { return V_55 }
    else if (hash == V54_HASH) { return V_54 }
    else if (hash == V53_HASH) { return V_53 }
    else { return V_DEFAULT }
}

// Docker image tag suffix from version number
public func docker_tag_suffix(v : int) : std::string_view {
    if (v == V_55) { return std::string_view("v0.5.5-ubuntu") }
    else if (v == V_54) { return std::string_view("v0.5.4-ubuntu") }
    else { return std::string_view("v0.5.3-ubuntu") }
}

// Display label for version dropdown
public func version_label(v : int) : std::string_view {
    if (v == V_55) { return std::string_view("v0.5.5") }
    else if (v == V_54) { return std::string_view("v0.5.4") }
    else { return std::string_view("v0.5.3") }
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
