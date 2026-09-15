// Tests for the SSR page renderers: src/pages/index.ch (MainPage) and
// src/pages/playground.ch (PlaygroundPage). These build the full HtmlPage the
// same way src/app/main.ch does, then assert on the rendered HTML.
using std::string
using std::string_view

func render_main_page() : std::string {
    var page = HtmlPage()
    MainPage(&mut page)
    page.appendTitle("Chemical | Programming Language")
    page.appendPngFavicon("Favicon.png")
    return page.toString()
}

func render_playground_page() : std::string {
    var page = HtmlPage()
    PlaygroundPage(&mut page)
    page.appendTitle("Playground | Chemical")
    page.appendPngFavicon("Favicon.png")
    return page.toString()
}

@test
public func test_main_page_renders_non_empty(env : &mut TestEnv) {
    var html = render_main_page()
    if (html.size() < 500) { env.error("main page html suspiciously small") }
}

@test
public func test_main_page_has_basic_document(env : &mut TestEnv) {
    var html = render_main_page()
    var view = html.to_view()
    if (view.find(std::string_view("<html")) == std::NPOS) { env.error("main page missing <html>") }
    if (view.find(std::string_view("</html>")) == std::NPOS) { env.error("main page missing </html>") }
    if (view.find(std::string_view("<body")) == std::NPOS) { env.error("main page missing <body>") }
}

@test
public func test_main_page_title(env : &mut TestEnv) {
    var html = render_main_page()
    var view = html.to_view()
    if (view.find(std::string_view("Chemical | Programming Language")) == std::NPOS) { env.error("main page title missing") }
}

@test
public func test_main_page_hero_and_cta(env : &mut TestEnv) {
    var html = render_main_page()
    var view = html.to_view()
    if (view.find(std::string_view("Systems programming")) == std::NPOS) { env.error("hero heading missing") }
    if (view.find(std::string_view("href=\"/playground\"")) == std::NPOS) { env.error("playground CTA link missing") }
    if (view.find(std::string_view("chemicallang.com/install.sh")) == std::NPOS) { env.error("install command missing") }
    if (view.find(std::string_view("code-window")) == std::NPOS) { env.error("hero code showcase missing") }
    if (view.find(std::string_view("install-tab")) == std::NPOS) { env.error("install tabs missing") }
    if (view.find(std::string_view("selectInstallTab")) == std::NPOS) { env.error("install tab switching logic missing") }
}

@test
public func test_main_page_download_section(env : &mut TestEnv) {
    var html = render_main_page()
    var view = html.to_view()
    if (view.find(std::string_view("github.com/chemicallang/chemical/releases")) == std::NPOS) { env.error("release download links missing") }
    if (view.find(std::string_view("Windows")) == std::NPOS || view.find(std::string_view("Linux")) == std::NPOS || view.find(std::string_view("macOS")) == std::NPOS) {
        env.error("OS download cards missing")
    }
}

@test
public func test_playground_page_renders_non_empty(env : &mut TestEnv) {
    var html = render_playground_page()
    if (html.size() < 500) { env.error("playground page html suspiciously small") }
}

@test
public func test_playground_page_title(env : &mut TestEnv) {
    var html = render_playground_page()
    var view = html.to_view()
    if (view.find(std::string_view("Playground | Chemical")) == std::NPOS) { env.error("playground page title missing") }
}

@test
public func test_playground_page_editor_elements(env : &mut TestEnv) {
    var html = render_playground_page()
    var view = html.to_view()
    // ids the client script and /submit endpoint depend on
    if (view.find(std::string_view("id=\"editor-container\"")) == std::NPOS) { env.error("editor container missing") }
    if (view.find(std::string_view("id=\"submit-btn\"")) == std::NPOS) { env.error("submit button missing") }
    if (view.find(std::string_view("id=\"error-box\"")) == std::NPOS) { env.error("error box missing") }
    if (view.find(std::string_view("id=\"examples\"")) == std::NPOS) { env.error("examples dropdown missing") }
}

@test
public func test_playground_page_submit_flow_wiring(env : &mut TestEnv) {
    var html = render_playground_page()
    var view = html.to_view()
    if (view.find(std::string_view("fetch(\"/submit\"")) == std::NPOS) { env.error("client script must POST to /submit") }
    if (view.find(std::string_view("main-file-btn")) == std::NPOS || view.find(std::string_view("mod-file-btn")) == std::NPOS) {
        env.error("editor file tab buttons missing")
    }
}

@test
public func test_playground_compilation_sets_examples(env : &mut TestEnv) {
    // the example sets embedded as string literals must remain intact
    var str_list = getStrListMapCompSet()
    if (str_list.main == null || str_list.mod == null) { env.error("string/map example set must carry main+mod sources") }
    var sv = std::string_view(str_list.main, strlen(str_list.main))
    if (sv.find(std::string_view("func main")) == std::NPOS) { env.error("string example main source missing") }

    var exprs = getExprStrCompSet()
    if (exprs.main == null) { env.error("expressive string example set must carry main source") }

    var comps = getComponentsCompSet()
    if (comps.main == null) { env.error("components example set must carry main source") }

    var langs = getEmbeddedLangsCompSet()
    if (langs.main == null) { env.error("embedded langs example set must carry main source") }
}
