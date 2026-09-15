// Endpoint tests: boot the real server with the same routes as
// src/app/main.ch and hit them over loopback with the http client. Mirrors
// underlayer's tests/src/health_test.ch pattern: each test inlines its own
// route registration because closures capture stack locals by reference
// (|&var|) — that only works for variables in the caller's scope.
using std::string
using std::string_view
using std::Result
using std::Option

// Port pool: one port per test so the suite runs in any order (underlayer style).
// NOTE: ServerConfig.addr must carry the port — its port part OVERRIDES the
// serve_async() argument (addr defaults to ":8080").
const PORT_HOME : uint = 20701u
const PORT_PLAYGROUND : uint = 20702u
const PORT_HEAD : uint = 20703u
const PORT_FAVICON : uint = 20704u
const PORT_LOGO : uint = 20705u
const PORT_INSTALL_SH : uint = 20706u
const PORT_INSTALL_PS1 : uint = 20707u
const PORT_TEST_SH : uint = 20708u
const PORT_TEST_PS1 : uint = 20709u
const PORT_SUBMIT : uint = 20710u
const PORT_NOT_FOUND : uint = 20711u

// Render the main page exactly like src/app/main.ch does.
func render_home_html() : std::string {
    var page = HtmlPage()
    MainPage(&mut page)
    page.appendTitle("Chemical | Programming Language")
    page.appendPngFavicon("Favicon.png")
    return page.toString()
}

// Render the playground page exactly like src/app/main.ch does.
func render_pg_html() : std::string {
    var page = HtmlPage()
    PlaygroundPage(&mut page)
    page.appendTitle("Playground | Chemical")
    page.appendPngFavicon("Favicon.png")
    return page.toString()
}

@test
public func test_home_returns_200_html(env : &mut TestEnv) {
    var completeMainPage = render_home_html()
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20701")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/", (|&completeMainPage|(req, res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"))
        res.write_view(completeMainPage.to_view())
    }))
    srv.serve_async(PORT_HOME)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20701/")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 200u) { env.error("expected status 200") }
    var ct = resp.headers.get("Content-Type")
    if (ct is Option.None) { env.error("missing Content-Type"); srv.shutdown(); return }
    var Some(ct_val) = ct else unreachable
    if (ct_val.find(std::string_view("text/html")) == std::NPOS) { env.error("Content-Type must be text/html") }

    srv.shutdown()
}

@test
public func test_home_body_contains_rendered_page(env : &mut TestEnv) {
    var completeMainPage = render_home_html()
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20701")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/", (|&completeMainPage|(req, res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"))
        res.write_view(completeMainPage.to_view())
    }))
    srv.serve_async(PORT_HOME)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20701/")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    var body_opt = resp.body.read_to_string()
    if (body_opt is Option.None) { env.error("no body"); srv.shutdown(); return }
    var Some(body) = body_opt else unreachable
    if (body.find(std::string_view("Chemical | Programming Language")) == std::NPOS) { env.error("body must contain rendered main page") }

    srv.shutdown()
}

@test
public func test_playground_endpoint_returns_editor_page(env : &mut TestEnv) {
    var completePgPage = render_pg_html()
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20702")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/playground", (|&completePgPage|(req, res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("text/html; charset=utf-8"))
        res.write_view(completePgPage.to_view())
    }))
    srv.serve_async(PORT_PLAYGROUND)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20702/playground")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 200u) { env.error("expected status 200") }
    var body_opt = resp.body.read_to_string()
    if (body_opt is Option.None) { env.error("no body"); srv.shutdown(); return }
    var Some(body) = body_opt else unreachable
    if (body.find(std::string_view("id=\"editor-container\"")) == std::NPOS) { env.error("playground body must contain editor") }

    srv.shutdown()
}

@test
public func test_head_root_returns_200(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20703")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("HEAD", "/", (req, res) => {
        res.set_cors(std::string_view("*"))
        res.status = 200u
        res.write_view(std::string_view())
    })
    srv.serve_async(PORT_HEAD)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.head("http://127.0.0.1:20703/")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 200u) { env.error("HEAD / must return 200 (domain ownership check)") }

    srv.shutdown()
}

@test
public func test_favicon_served_from_dev_assets(env : &mut TestEnv) {
    // tests always run in def.debug, so the app resolves assets relative to
    // the repo root — serve from the repo root working dir to match.
    var which_favicon = std::string_view("lang/compiled/playground/src/assets/Favicon.png")
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20704")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/Favicon.png", |&which_favicon|(req, res) => {
        if (!res.send_file(which_favicon, std::string_view("image/png"))) {
            res.status = 404u
            res.set_header_view(std::string_view("Content-Type"), std::string_view("text/plain"))
            res.write_string(std::string::make_no_len("Not Found\n"))
        }
    })
    srv.serve_async(PORT_FAVICON)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20704/Favicon.png")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 200u) { env.error("dev favicon must resolve from lang/compiled/playground/src/assets/") }

    srv.shutdown()
}

@test
public func test_logo_served_from_dev_assets(env : &mut TestEnv) {
    var which_logo = std::string_view("lang/compiled/playground/src/assets/Logo.png")
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20705")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/Logo.png", |&which_logo|(req, res) => {
        if (!res.send_file(which_logo, std::string_view("image/png"))) {
            res.status = 404u
            res.set_header_view(std::string_view("Content-Type"), std::string_view("text/plain"))
            res.write_string(std::string::make_no_len("Not Found\n"))
        }
    })
    srv.serve_async(PORT_LOGO)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20705/Logo.png")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 200u) { env.error("dev logo must resolve from lang/compiled/playground/src/assets/") }

    srv.shutdown()
}

@test
public func test_install_sh_redirects(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20706")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/install.sh", (req, res) => {
        res.status = 302u
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/download.sh"))
        res.write_view(std::string_view("Redirecting to install script...\n"))
    })
    srv.serve_async(PORT_INSTALL_SH)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20706/install.sh")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 302u) { env.error("install.sh must redirect with 302") }
    var loc = resp.headers.get("Location")
    if (loc is Option.None) { env.error("missing Location header"); srv.shutdown(); return }
    var Some(loc_val) = loc else unreachable
    if (loc_val.find(std::string_view("scripts/download.sh")) == std::NPOS) { env.error("install.sh must redirect to download.sh") }

    srv.shutdown()
}

@test
public func test_test_sh_redirects(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20708")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/test.sh", (req, res) => {
        res.status = 302u
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/run-tests.sh"))
        res.write_view(std::string_view("Redirecting to test script...\n"))
    })
    srv.serve_async(PORT_TEST_SH)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20708/test.sh")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 302u) { env.error("test.sh must redirect with 302") }
    var loc = resp.headers.get("Location")
    if (loc is Option.None) { env.error("missing Location header"); srv.shutdown(); return }
    var Some(loc_val) = loc else unreachable
    if (loc_val.find(std::string_view("scripts/run-tests.sh")) == std::NPOS) { env.error("test.sh must redirect to run-tests.sh") }

    srv.shutdown()
}

@test
public func test_install_ps1_redirects(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20707")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/install.ps1", (req, res) => {
        res.status = 302u
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/download.ps1"))
        res.write_view(std::string_view("Redirecting to install script...\n"))
    })
    srv.serve_async(PORT_INSTALL_PS1)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20707/install.ps1")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 302u) { env.error("install.ps1 must redirect with 302") }

    srv.shutdown()
}

@test
public func test_test_ps1_redirects(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20709")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/test.ps1", (req, res) => {
        res.status = 302u
        res.set_header_view(std::string_view("Location"), std::string_view("https://raw.githubusercontent.com/chemicallang/chemical/main/scripts/run-tests.ps1"))
        res.write_view(std::string_view("Redirecting to test script...\n"))
    })
    srv.serve_async(PORT_TEST_PS1)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20709/test.ps1")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status != 302u) { env.error("test.ps1 must redirect with 302") }

    srv.shutdown()
}

@test
public func test_submit_rejects_bad_json(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20710")
    cfg.worker_count = 4u
    cfg.max_body_bytes = 10u * 1024u * 1024u
    var srv = server.Server(cfg)
    // minimal /submit that exercises the same parse-or-error path as the app:
    // unparsable body must yield the error envelope with application/json.
    srv.router.add("POST", "/submit", (req, res) => {
        res.set_header_view(std::string_view("Content-Type"), std::string_view("application/json; charset=utf-8"))
        var body_opt = req.body.read_to_string()
        if (body_opt is std.Option.Some) {
            var Some(value) = body_opt else unreachable
            var parser = JsonParser(128, 4096)
            var astHandler = ASTJsonHandler()
            var result = parser.parse(value.data(), value.size(), &mut astHandler)
            if (!result.ok) {
                res.write_view(std::string_view("{ \"type\" : \"error\", \"message\" : \"couldn't parse json\" }"))
                return
            }
        }
        res.write_view(std::string_view("{ \"type\" : \"error\", \"message\" : \"couldn't parse json\" }"))
    })
    srv.serve_async(PORT_SUBMIT)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.post("http://127.0.0.1:20710/submit", "this is not json")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    var body_opt = resp.body.read_to_string()
    if (body_opt is Option.None) { env.error("no body"); srv.shutdown(); return }
    var Some(body) = body_opt else unreachable
    if (body.find(std::string_view("\"type\" : \"error\"")) == std::NPOS) { env.error("bad json must yield error envelope") }
    if (body.find(std::string_view("couldn't parse json")) == std::NPOS) { env.error("error message mismatch") }

    srv.shutdown()
}

@test
public func test_unknown_route_not_ok(env : &mut TestEnv) {
    var cfg = server.ServerConfig()
    cfg.addr = std::string("127.0.0.1:20711")
    cfg.worker_count = 4u
    var srv = server.Server(cfg)
    srv.router.add("GET", "/", (req, res) => {
        res.status = 200u
        res.write_view(std::string_view("home"))
    })
    srv.serve_async(PORT_NOT_FOUND)
    std::concurrent.sleep_ms(200u)

    var client = http::Client()
    var res = client.get("http://127.0.0.1:20711/definitely/not/here")
    if (res is Result.Err) { env.error("request failed"); srv.shutdown(); return }
    var Ok(resp) = res else unreachable
    if (resp.status == 200u) { env.error("unknown route must not return 200") }

    srv.shutdown()
}
