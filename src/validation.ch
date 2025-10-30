// return true if filename is safe (no absolute paths, no .. segments, allowed chars)
func is_valid_filename(name : std::string_view) : bool {
    if (name.size() == 0) return false
    // disallow absolute paths
    if (name.get(0) == '/' || name.get(0) == '\\') return false
    // disallow windows drive letter form like "C:" at start
    if (name.size() >= 2 && ((name.get(1) == ':' && ((name.get(0) >= 'A' && name.get(0) <= 'Z') || (name.get(0) >= 'a' && name.get(0) <= 'z'))))) {
        return false
    }
    // disallow path traversal
    var i : uint = 0
    while (i < name.size()) {
        // if we find ".." segment
        if (name.get(i) == '.' && i + 1 < name.size() && name.get(i + 1u) == '.') {
            // check boundaries: either start, or surrounded by separators
            var before = (i == 0u) || (name.get(i - 1u) == '/' || name.get(i - 1u) == '\\')
            var after = (i + 2u == name.size()) || (name.get(i + 2u) == '/' || name.get(i + 2u) == '\\')
            if (before && after) { return false }
        }
        // restrict characters to reasonable set
        var c = name.get(i)
        if (!((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '.' || c == '_' || c == '-' || c == '/' || c == '\\')) {
            return false
        }
        i++
    }
    return true
}