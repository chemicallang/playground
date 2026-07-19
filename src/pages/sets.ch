
struct CompilationSet {
    var main : *char
    var mod : *char
}

func getStrListMapCompSet() : CompilationSet {
    return CompilationSet {
        main : """
// please note that this stuff is experimental
// expected to mostly work, if fails, file an issue

public func main() : int {
    // creating a string
    var str = std::string()
    str.append_view(std::string_view("Your name is "))
    str.append_view("Patrick, You have ")
    str.append_integer(5)
    str.append_view(" apples")
    printf("Final String : '%s'\\n", str.data());

    // substr
    var substr = str.substring(13, 20)
    printf("The name is 'Mamdani', no wait its '%s'\\n", substr.data());

    // creating a vector
    var vec = std::vector<int>()
    vec.push(10)
    vec.push(20)
    vec.push(30)
    vec.push(40)
    printf("Your vector contains : ")
    print_vec(&vec)
    vec.clear()
    printf("Your vector contains : ")
    print_vec(&vec)

    // creating map
    var map = std::unordered_map<std::string_view, std::string_view>()
    map.insert(std::string_view("person1"), std::string_view("Patrick"))
    map.insert(std::string_view("person2"), std::string_view("Ulrich"))
    map.insert(std::string_view("person3"), std::string_view("Sarah"))
    map.insert(std::string_view("person4"), std::string_view("Scott"))
    map.insert(std::string_view("person5"), std::string_view("Yuri"))
    print_map(&map)
    printf("does the map contain person5 ? ");
    if(map.contains(std::string_view("person5"))) {
        printf("Yes\\n");
    } else {
        printf("No\\n");
    }
    printf("does the map contain Person8 ? ");
    if(map.contains(std::string_view("Person8"))) {
        printf("Yes\\n");
    } else {
        printf("No\\n");
    }
    return 0;
}

func print_vec(vec : &std::vector<int>) {
    var start = vec.data()
    const end = start + vec.size()
    if(start == end) {
       printf("empty vector\\n");
       return;
    }
    while(start != end) {
        printf("%d, ", *start);
        start++
    }
    printf("\\n");
}

func print_map(map : &std::unordered_map<std::string_view, std::string_view>) {
    printf("your map contains: {\\n");
    var itr = map.iterator()
    while(itr.valid()) {
        var k = itr.key()
        var v = itr.value()
        printf("\\t%s : %s\\n", k.data(), v.data());
        itr.next()
    }
    printf("}\\n");
}
""",
        mod : """
application main
source "main.ch"
import std
"""
    }
}

func getExprStrCompSet() : CompilationSet {
    return CompilationSet {
        main : """
// please note that this stuff is experimental
// expected to mostly work, if fails, file an issue

public func main() : int {

    // lets try some expressive strings
    var str = std::string()
    var day = "Friday"
    var count = 7
    str.append_expr(\`Today is \${day} and there are \${count} days in a week\`)
    printf("%s\\n", str.data());

    // send to command line
    var pi = 3.14f
    var msg = "I remember it"
    println(\`The value of pi is \${pi} and \${msg}\`)


    print(\`${"\\n\\n"}Long Live Chemical${"\\n\\n"}\`)
    return 0;
}
"""
        mod : """
application main
source "main.ch"
import std
"""
    }
}

func getEmbeddedLangsCompSet() : CompilationSet {
    return CompilationSet {
        main : """
// please note that this stuff is experimental

func give_me_fruit() : *char {
    return "Bell pepper"
}

func style_banana(page : &mut HtmlPage) : *char {
    // notice: multiple invocations of this function won't cause multiple styles
    return #css {
       color : yellow;
       background-color : red;
       padding : 6px;
       border-radius : 6px;
    }
}

func color_cucumber() : *char {
    return "green"
}

func style_cucumber(page : &mut HtmlPage) : *char {
    return #css {
        color : {color_cucumber()};
    }
}

func MainPage(page : &mut HtmlPage) {
    #html {
       <div id="fruits" class="lists-container">
         <ul>
             <li class={style_banana(page)}>Banana</li>
             <li class={style_cucumber(page)}>Pineapple</li>
             <li class={style_cucumber(page)}>Cucumber</li>
             <li>Tomato</li>
             <li>{give_me_fruit()}</li>
         </ul>
       </div>
    }
}

public func main() : int {

    var page = HtmlPage()
    MainPage(page)

    printf("%!webview:");
    var completePage = page.toString();
    printf("%s\\n", completePage.data())

    return 0;
}
"""
        mod : """
application main
source "main.ch"
import std
import html_cbi
import css_cbi
import page
"""
    }
}

func getComponentsCompSet() : CompilationSet {
    return CompilationSet {
        main : """
// please note that this stuff is experimental

#react ReactCounter(props) {
    var [count, setCount] = useState(0)
    return (
        <div style={{ textAlign: 'center', padding: '2rem', background: 'rgba(255,255,255,0.03)', borderRadius: '24px', border: '1px solid rgba(255,255,255,0.1)' }}>
            <h3 style={{ color: '#61dafb', marginBottom: '1.5rem' }}>React</h3>
            <button
                onClick={() => setCount((c) => c + 1)}
                className={props.className}
                style={{ cursor: 'pointer', transition: 'all 0.2s' }}
            >
                Count: {count}
            </button>
        </div>
    )
}

#preact PreactCounter(props) {
    var [count, setCount] = useState(0)
    return (
        <div style={{ textAlign: 'center', padding: '2rem', background: 'rgba(255,255,255,0.03)', borderRadius: '24px', border: '1px solid rgba(255,255,255,0.1)' }}>
            <h3 style={"color: #673ab8; margin-bottom: 1.5rem"}>Preact</h3>
            <button onClick={() => setCount((c) => c + 1)} className={props.className}>
                Count: {count}
            </button>
        </div>
    )
}

#solid SolidCounter(props) {
    var [count, setCount] = createSignal(0)
    return (
        <div style={{ 'text-align': 'center', padding: '2rem', background: 'rgba(255,255,255,0.03)', 'border-radius': '24px', border: '1px solid rgba(255,255,255,0.1)' }}>
            <h3 style={"color: #2c4f7c; margin-bottom: 1.5rem"}>Solid</h3>
            <button onClick={() => setCount((c) => c + 1)} className={props.className}>
                Count: {count()}
            </button>
        </div>
    )
}

func MainPage(page : &mut HtmlPage) {

    page.defaultPrepare()
    page.defaultPreactSetup()
    page.defaultReactSetup()
    page.defaultSolidSetup()
    page.appendTitle("Component Interaction - Chemical")

    var btnStyle = #css {
        padding: 0.75rem 2rem; border-radius: 12px; border: none; font-weight: 700;
        background: linear-gradient(135deg, #00d4ff, #9130ff); color: #fff;
        box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3); letter-spacing: 0.05em;
    }

    #css {
        .page-header { padding: 12rem 0 4rem; text-align: center; }
        .page-header h1 { font-size: 3.5rem; margin-bottom: 1rem; }
        .page-header p { color: #666; max-width: 600px; margin: 0 auto; }

        .comp-showcase { display: grid; grid-template-columns: repeat(3, 1fr); gap: 3rem; margin-top: 4rem; }
        .comp-item { animation: float 6s ease-in-out infinite; }
        .comp-item:nth-child(2) { animation-delay: 1s; }
        .comp-item:nth-child(3) { animation-delay: 2s; }
    }

    #html {
       <div>
           <div class="comp-showcase">
               <div class="comp-item">
                   <ReactCounter className={btnStyle} />
               </div>
               <div class="comp-item">
                   <PreactCounter className={btnStyle} />
               </div>
               <div class="comp-item">
                   <SolidCounter className={btnStyle} />
               </div>
           </div>
       </div>
    }

}

public func main() : int {

    var page = HtmlPage()
    MainPage(page)

    printf("%!webview:");
    var completePage = page.toString();
    printf("%s\\n", completePage.data())

    return 0;
}
"""
        mod : """
application main
source "main.ch"
import std
import html_cbi
import css_cbi
import page
import react_cbi
import solid_cbi
import preact_cbi
import md_cbi
"""
    }
}
// ===== Library Examples =====

func getFileopsSet() : CompilationSet {
    return CompilationSet {
        main : """
// File System - create, read, write, delete files

using namespace std;
using namespace fs;

public func main() : int {
    var dir = string("_demo");
    fs::remove_dir_all_recursive(dir.data());
    fs::create_dir(dir.data());

    var path = string();
    path.append_char_ptr(dir.data());
    path.append_view("/hello.txt");

    var content = "Hello from Chemical!\\n";
    fs::write_text_file(path.data(), content as *u8, strlen(content) as size_t);

    var rd = fs::read_entire_file(path.data());
    if(rd is Result.Ok) {
        var Ok(vec) = rd else unreachable;
        printf("Read: %s", vec.data() as *char);
        printf("Size: %zu bytes\\n", vec.size());
    }

    var m = fs::metadata(path.data());
    if(m is Result.Ok) {
        var Ok(meta) = m else unreachable;
        printf("File: %s, Size: %zu\\n", if(meta.is_file) "yes" else "no", meta.len);
    }

    fs::remove_dir_all_recursive(dir.data());
    printf("Done!\\n");
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import fs
import std
import cstd
"""
    }
}

func getTimetellerSet() : CompilationSet {
    return CompilationSet {
        main : """
// Date & Time - create, format, compare dates

using namespace std;
using namespace datetime;

public func main() : int {
    var now = std::chrono::SystemTime::now();
    var dt_now = DateTime::from_system_time(&now);
    printf("Now (UTC): %s\\n", dt_now.format("%Y-%m-%d %H:%M:%S").data());

    var dt = DateTime::from_components(2024, 12, 25, 10, 30, 45, 0, TimeZone::utc());
    printf("Xmas 2024: %s\\n", dt.format("%Y-%m-%d %H:%M:%S").data());
    printf("Day of week: %lld, Day of year: %lld\\n", dt.day_of_week_val(), dt.day_of_year_val());

    var ist = TimeZone::fixed(19800, string_view("IST"));
    var dt_ist = DateTime::from_components(2024, 6, 15, 17, 30, 0, 0, ist);
    printf("IST time: %s\\n", dt_ist.format("%Y-%m-%d %H:%M:%S %z").data());

    var dur = std::chrono::Duration::from_secs(86400 * 7);
    var future = dt.add_duration(&dur);
    printf("Xmas + 7d: %s\\n", future.format("%Y-%m-%d").data());

    printf("Leap 2000=%s, 2024=%s, 1900=%s\\n",
        if(is_leap_year(2000)) "yes" else "no",
        if(is_leap_year(2024)) "yes" else "no",
        if(is_leap_year(1900)) "yes" else "no");
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import datetime
import std
import cstd
"""
    }
}

func getJsnSet() : CompilationSet {
    return CompilationSet {
        main : """
// JSON - parse, access, and encode JSON

using namespace std;

public func main() : int {
    var input = string_view("{\"name\":\"Alice\",\"age\":30,\"active\":true}");
    var ph = ASTJsonHandler();
    var parser = JsonParser(128, 4096);
    var r = parser.parse(input.data(), input.size(), &mut ph);
    if(!r.ok) { printf("Parse failed: %s\\n", r.msg); return 1; }
    printf("Parsed OK: %s\\n", encode_json(&ph.root).data());

    var arr = string_view("[1, 2, 3, \"four\", true, null]");
    var ph2 = ASTJsonHandler();
    var parser2 = JsonParser(128, 4096);
    parser2.parse(arr.data(), arr.size(), &mut ph2);
    printf("Array: %s\\n", encode_json(&ph2.root).data());

    var output = string();
    var counts = vector<u64>();
    var encoder = JsonEncoder { buffer : &raw mut output, counts : &raw mut counts };
    encoder.encode_null();
    printf("null -> %s\\n", output.data());

    output.clear();
    var encoder2 = JsonEncoder { buffer : &raw mut output, counts : &raw mut counts };
    encoder2.encode_str("hello chemical");
    printf("str -> %s\\n", output.data());

    return 0;
}
""",
        mod : """
application main
source "main.ch"
import json
import std
import cstd
"""
    }
}

func getUuidgenSet() : CompilationSet {
    return CompilationSet {
        main : """
// UUID - generate and parse UUIDs

using namespace std;
using namespace uuid;

public func main() : int {
    printf("UUID v4 (random):\\n");
    for(var i = 0; i < 3; i++) {
        printf("  %s\\n", uuid::v4().to_string().data());
    }

    printf("\\nUUID v7 (time-ordered):\\n");
    for(var i = 0; i < 3; i++) {
        printf("  %s\\n", uuid::v7().to_string().data());
    }

    var parsed = uuid::parse(string_view("550e8400-e29b-41d4-a716-446655440000"));
    if(parsed is Result.Ok) {
        var Ok(u) = parsed else unreachable;
        printf("\\nParsed: %s\\n", u.to_string().data());
    }

    var u1 = uuid::v4();
    var u2 = uuid::v4();
    printf("\\nu1 == u2: %s\\n", if(u1.equals(&u2)) "true" else "false");
    printf("u1 cmp u2: %d\\n", u1.compare(&u2));
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import uuid
import std
import cstd
"""
    }
}

func getHashpassSet() : CompilationSet {
    return CompilationSet {
        main : """
// Bcrypt - hash and verify passwords

using namespace std;

public func main() : int {
    var password = string_view("my_secure_p@ss!");
    printf("Password: %s\\n", password.data());

    var hash = bcrypt::hash_password(password);
    if(hash.empty()) { printf("Hashing failed!\\n"); return 1; }
    printf("Hash: %s\\n", hash.data());

    var ok = bcrypt::check_password(password, hash.to_view());
    printf("Verify correct: %s\\n", if(ok) "MATCH" else "FAIL");

    var bad = bcrypt::check_password(string_view("wrong!"), hash.to_view());
    printf("Verify wrong:   %s\\n", if(bad) "MATCH" else "REJECTED");

    var salt = bcrypt::generate_salt(10);
    printf("Salt (cost=10): %s\\n", salt.data());
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import bcrypt
import std
import cstd
"""
    }
}

func getFetchrSet() : CompilationSet {
    return CompilationSet {
        main : """
// HTTP Client - fetch web resources

using namespace std;
using namespace http;

var test_html = #html {
    <html><body>
        <h1>Hello from Chemical!</h1>
        <p>This response was served by a Chemical HTTP server.</p>
        <ul>
            <li>Zero-copy routing</li>
            <li>Header-based content negotiation</li>
        </ul>
    </body></html>
};

public func main() : int {
    printf("Starting local server...\\n");
    var cfg = server::ServerConfig();
    cfg.addr = string::make_no_len("127.0.0.1:9090");
    var srv = server::Server(cfg);

    srv.router.add("GET", "/", ||(req, res) => {
        res.write_string(string::make_no_len("Hello from Chemical HTTP!"));
    });

    srv.router.add("GET", "/api", ||(req, res) => {
        res.set_header(string::make_no_len("Content-Type"), string::make_no_len("application/json"));
        res.write_string(string::make_no_len("{\"lang\":\"Chemical\",\"version\":\"0.0.32\"}"));
    });

    var thread = srv.serve_async(9090u);
    std::concurrent::sleep_ms(200u);

    var client = http::Client();

    var r1 = client.get(string_view("http://127.0.0.1:9090/"));
    if(r1 is Result.Ok) {
        var Ok(resp) = r1 else unreachable;
        var str = resp.body.read_to_string();
        var body = str.take();
        printf("GET /: %s (status=%u)\\n", body.data(), resp.status);
    }

    var r2 = client.get(string_view("http://127.0.0.1:9090/api"));
    if(r2 is Result.Ok) {
        var Ok(resp) = r2 else unreachable;
        var str = resp.body.read_to_string();
        var body = str.take();
        printf("GET /api: %s\\n", body.data());
    }

    srv.shutdown();
    thread.join();
    printf("Done!\\n");
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import http
import net
import std
import cstd
"""
    }
}

func getEnvbeeSet() : CompilationSet {
    return CompilationSet {
        main : """
// Environment - get/set environment variables

using namespace std;
using namespace environment;

public func main() : int {
    var home_opt = environment::home_dir();
    if(home_opt is Option.Some) {
        var Some(home) = home_opt else unreachable;
        printf("HOME: %s\\n", home.data());
    }

    var user_opt = environment::user_name();
    if(user_opt is Option.Some) {
        var Some(user) = user_opt else unreachable;
        printf("USER: %s\\n", user.data());
    }

    var shell_opt = environment::shell();
    if(shell_opt is Option.Some) {
        var Some(s) = shell_opt else unreachable;
        printf("SHELL: %s\\n", s.data());
    }

    var lang = environment::get_or(string_view("LANG"), string_view("en_US.UTF-8"));
    printf("LANG: %s\\n", lang.data());

    var set_r = environment::set(string_view("CHEMICAL_DEMO"), string_view("works!"));
    if(set_r is Result.Ok) {
        var check = environment::get(string_view("CHEMICAL_DEMO"));
        if(check is Option.Some) {
            var Some(v) = check else unreachable;
            printf("CHEMICAL_DEMO: %s\\n", v.data());
        }
        environment::unset(string_view("CHEMICAL_DEMO"));
    }
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import environment
import std
import cstd
"""
    }
}

func getRunprocSet() : CompilationSet {
    return CompilationSet {
        main : """
// Process - run system commands

using namespace std;
using namespace process;

public func main() : int {
    printf("Running 'echo hello':\\n");
    var args = vector<string_view>();
    args.push(string_view("hello from Chemical"));
    var r = process::run(string_view("echo"), args);
    if(r is Result.Ok) {
        var Ok(result) = r else unreachable;
        var out = string(result.output.stdout_data.data() as *char, result.output.stdout_data.size());
        printf("  stdout: %s", out.data());
        printf("  exit: %d, success: %s\\n", result.status.code, if(result.success) "true" else "false");
    }

    printf("\\nShell command 'whoami':\\n");
    var r2 = process::run_shell(string_view("whoami"));
    if(r2 is Result.Ok) {
        var Ok(result) = r2 else unreachable;
        var out = string(result.output.stdout_data.data() as *char, result.output.stdout_data.size());
        printf("  user: %s", out.data());
    }

    printf("\\nDirect ProcessConfig:\\n");
    var cfg = ProcessConfig.default();
    cfg.args.push(string("echo"));
    cfg.args.push(string("Process library works!"));
    var r3 = process::execute(cfg);
    if(r3 is Result.Ok) {
        var Ok(result) = r3 else unreachable;
        var out = string(result.output.stdout_data.data() as *char, result.output.stdout_data.size());
        printf("  %s", out.data());
    }
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import process
import std
import cstd
"""
    }
}

func getPathwaysSet() : CompilationSet {
    return CompilationSet {
        main : """
// Paths - manipulate file paths

using namespace std;
using namespace path;

public func main() : int {
    var buf : [4096]char;

    var r = path::basename("/usr/bin/gcc", &raw mut buf[0], 4096);
    if(r is Result.Ok) { printf("basename('/usr/bin/gcc'): %s\\n", buf); }

    var r2 = path::dirname("/usr/bin/gcc", &raw mut buf[0], 4096);
    if(r2 is Result.Ok) { printf("dirname('/usr/bin/gcc'):  %s\\n", buf); }

    var r3 = path::extension("archive.tar.gz", &raw mut buf[0], 4096);
    if(r3 is Result.Ok) { printf("extension('archive.tar.gz'): '%s'\\n", buf); }

    var r4 = path::stem("file.txt", &raw mut buf[0], 4096);
    if(r4 is Result.Ok) { printf("stem('file.txt'):          %s\\n", buf); }

    var r5 = path::join("/usr", "bin/gcc", &raw mut buf[0], 4096);
    if(r5 is Result.Ok) { printf("join('/usr','bin/gcc'):    %s\\n", buf); }

    var r6 = path::normalize("/usr/bin/../lib/./file.txt", &raw mut buf[0], 4096);
    if(r6 is Result.Ok) { printf("normalize:                 %s\\n", buf); }

    printf("is_absolute('/usr'): %s\\n", if(path::is_absolute("/usr")) "true" else "false");
    printf("is_absolute('rel'):  %s\\n", if(path::is_absolute("rel")) "true" else "false");
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import path
import std
import cstd
"""
    }
}

func getDigestSet() : CompilationSet {
    return CompilationSet {
        main : """
// Crypto - SHA-256, MD5, Base64, HMAC

using namespace std;

func print_hex(label : *char, data : *u8, len : size_t) {
    printf("%s: ", label);
    for(var i = 0u; i < len; i++) {
        printf("%02x", data[i] as uint);
    }
    printf("\\n");
}

public func main() : int {
    var data : [5]u8 = [ 0x48, 0x65, 0x6C, 0x6C, 0x6F ]; // "Hello"

    var sha : [32]u8;
    crypto::sha256_hash(&raw data[0], 5, &raw mut sha[0]);
    print_hex("SHA-256", &raw sha[0], 32);

    var md : [16]u8;
    crypto::md5_hash(&raw data[0], 5, &raw mut md[0]);
    print_hex("MD5", &raw md[0], 16);

    var b64 : [128]char;
    var r = crypto::base64_encode(&raw data[0], 5, &raw mut b64[0], 128);
    if(r is Result.Ok) { printf("Base64: %s\\n", b64); }

    var a : [3]u8 = [1, 2, 3];
    var b : [3]u8 = [1, 2, 3];
    var c : [3]u8 = [1, 0xFF, 3];
    printf("const_time_equal: a==b: %s, a==c: %s\\n",
        if(crypto::constant_time_equal(&raw a[0], &raw b[0], 3)) "true" else "false",
        if(crypto::constant_time_equal(&raw a[0], &raw c[0], 3)) "true" else "false");
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import crypto
import std
import cstd
"""
    }
}

func getShrinkitSet() : CompilationSet {
    return CompilationSet {
        main : """
// Compression - RLE encode/decode

using namespace std;

public func main() : int {
    var input : [12]u8 = [ 0x41, 0x41, 0x41, 0x41, 0x42, 0x42, 0x42, 0x42, 0x43, 0x44, 0x44, 0x44 ];
    var compressed : [64]u8;
    var comp_len : size_t = 0;

    var r = compression::compress(&raw input[0], 12, &raw mut compressed[0], &raw mut comp_len, 64);
    if(r is Result.Err) { printf("Compress failed!\\n"); return 1; }
    printf("Original: 12 bytes -> Compressed: %zu bytes\\n", comp_len);

    var decompressed : [64]u8;
    var dec_len : size_t = 0;
    var r2 = compression::decompress(&raw compressed[0], comp_len, &raw mut decompressed[0], &raw mut dec_len, 64);
    if(r2 is Result.Err) { printf("Decompress failed!\\n"); return 1; }
    printf("Decompressed: %zu bytes: ", dec_len);
    for(var i = 0u; i < dec_len; i++) {
        printf("%c", decompressed[i] as char);
    }
    printf("\\n");

    var same : [30]u8;
    for(var i = 0u; i < 30u; i++) { same[i] = 0xFF; }
    var tlen : size_t = 0;
    compression::compress(&raw same[0], 30, &raw mut compressed[0], &raw mut tlen, 64);
    printf("30 identical bytes -> %zu bytes (%.0f%% reduction)\
", tlen, (30u - tlen) as float / 30.0f * 100.0f);

    var rle = compression::RleCompressor{};
    printf("Algorithm: %s\\n", rle.name().data());
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import compression
import std
import cstd
"""
    }
}

func getHexitSet() : CompilationSet {
    return CompilationSet {
        main : """
// Encoding - hex, URL, UTF-8 utilities

using namespace std;

public func main() : int {
    var data : [5]u8 = [ 0x48, 0x65, 0x6C, 0x6C, 0x6F ];
    var buf : [128]char;

    encoding::hex_encode(&raw data[0], 5, &raw mut buf[0], 128);
    printf("Hex encode: %s\\n", buf);

    encoding::hex_encode_upper(&raw data[0], 5, &raw mut buf[0], 128);
    printf("Hex upper:  %s\\n", buf);

    var dec : [64]u8;
    var r = encoding::hex_decode("48656C6C6F", &raw mut dec[0], 64);
    if(r is Result.Ok) {
        var Ok(len) = r else unreachable;
        printf("Hex decode: ");
        for(var i = 0u; i < len; i++) printf("%c", dec[i] as char);
        printf("\\n");
    }

    encoding::url_encode("hello world!?q=test", 19, &raw mut buf[0], 128);
    printf("URL encode: %s\\n", buf);

    encoding::url_decode("hello+world%21", 14, &raw mut buf[0], 128);
    printf("URL decode: %s\\n", buf);

    printf("UTF-8 valid 'hello':   %s\\n", if(encoding::utf8_is_valid("hello", 5)) "yes" else "no");
    printf("UTF-8 valid cafe:     %s\\n", if(encoding::utf8_is_valid("caf\xC3\xA9", 5)) "yes" else "no");
    printf("UTF-8 invalid bytes:  %s\\n", if(encoding::utf8_is_valid("\xFF\xFE", 2)) "yes" else "no");

    printf("Char len 0xC0: %zu\\n", encoding::utf8_char_len(0xC0));
    printf("Char len 0xF0: %zu\\n", encoding::utf8_char_len(0xF0));
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import encoding
import std
import cstd
"""
    }
}

func getDocsmithSet() : CompilationSet {
    return CompilationSet {
        main : """
// DocGen - generate documentation from Markdown

using namespace std;
using namespace fs;

public func main() : int {
    var dir = string("_docs_demo");
    fs::remove_dir_all_recursive(dir.data());
    fs::create_dir(dir.data());

    var summary_path = string();
    summary_path.append_char_ptr(dir.data());
    summary_path.append_view("/SUMMARY.md");

    var summary = "# My Docs\\n\\n- [Intro](intro.md)\\n- [API](api.md)\\n";
    fs::write_text_file(summary_path.data(), summary as *u8, strlen(summary) as size_t);

    var intro_path = string();
    intro_path.append_char_ptr(dir.data());
    intro_path.append_view("/intro.md");

    var intro = "# Introduction\\n\\nWelcome to Chemical!\\n";
    fs::write_text_file(intro_path.data(), intro as *u8, strlen(intro) as size_t);

    var api_path = string();
    api_path.append_char_ptr(dir.data());
    api_path.append_view("/api.md");

    var api = "# API Reference\\n\\n## func main()\\nEntry point.\\n";
    fs::write_text_file(api_path.data(), api as *u8, strlen(api) as size_t);

    printf("Building docs from SUMMARY.md...\\n");
    docgen::build_docs(summary_path.data(), dir.data());

    var index_path = string();
    index_path.append_char_ptr(dir.data());
    index_path.append_view("/book/index.html");

    var rd = fs::read_entire_file(index_path.data());
    if(rd is Result.Ok) {
        var Ok(vec) = rd else unreachable;
        printf("Generated: book/index.html (%zu bytes)\\n", vec.size());
    } else {
        printf("Doc output not found!\\n");
    }

    fs::remove_dir_all_recursive(dir.data());
    printf("Done!\\n");
    return 0;
}
""",
        mod : """
application main
source "main.ch"
import docgen
import fs
import std
import cstd
"""
    }
}
