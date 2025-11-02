import "@html/page.ch"

func error_box_container(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        padding : 1em;
        display : none;
    }
}

func error_msg_container(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        padding : 1em;
        border-radius : 4px;
        background-color : rgb(14 91 192 / 33%);
        border : 2px solid rgba(0,0,0,.7);
    }
}

func textarea_container(page : &mut HtmlPage) : *char {
    return #css {
        display : flex;
        flex-direction:row;
        width : 100%;
        padding : 1em;
        gap : 1em;
    }
}

func editor_area(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        height : 100%;
        min-height : 80vh;
        background-color : rgba(0,0,0,.2);
        outline : 0;
        padding : 1em;
        border : 1px solid white;
        border-radius : 3px;
        color:white;
    }
}

func display_editor(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        height : 100%;
        min-height : 80vh;
        background-color : rgba(0,0,0,.2);
        outline : 0;
        padding : 1em;
        border : 1px solid white;
        border-radius : 3px;
        color : white;
    }
}

func editor_container(page : &mut HtmlPage) : *char {
    return #css {
        display : flex;
        flex-direction : column;
        width : 100%;
    }
}

func editor_toolbar(page : &mut HtmlPage) : *char {
    return #css {
        display : flex;
        flex-direction : row;
        gap : 0.5em;
    }
}

func editor_tab_button(page : &mut HtmlPage) : *char {
    return #css {
        padding : 10px 12px;
        background-color : rgba(255,255,255,.2);
        border-top-left-radius : 6px;
        border-top-right-radius : 6px;
        border : 0;
        color : white;
    }
}

func editor_tab_button_primary(page : &mut HtmlPage) : *char {
    return #css {
        padding : 10px 12px;
        background-color : #8b5cf6;
        border-top-left-radius : 6px;
        border-top-right-radius : 6px;
        border : 0;
        color : white;
    }
}

func PlaygroundPage(page : &mut HtmlPage) {
    #html {
        <style>{"""
            button.active {
                background-color : #8b5cf6;
            }
        """}</style>
        <script>{"""

            // 0 -> output, 1 -> llvm ir, 2 -> c translation, 4 -> compiler output
            let outputType = 0;
            let tabs = [
                {
                    name : "main.ch",
                    index : 0,
                    btnElem : null,
                    content : `@extern
public func printf(format : *char, _ : any...)
public func main() : int {
    printf("Hello World");
    return 0;
}`
                },
                {
                    name : "chemical.mod",
                    index : 1,
                    btnElem : null,
                    content : `module main
source "main.ch"
`
                }
            ]
            let activeTab = 0

            let mainOutputText = ""
            let llvmIrOutputText = ""
            let cTranslationOutputText = ""
            let compilerOutputText = ""

            document.addEventListener("DOMContentLoaded", () => {

                let errorBox = document.getElementById("error-box")
                let errorBoxMsg = document.getElementById("error-box-msg")

                let opOutBtn = document.getElementById("output-type-output-btn")
                let opIrBtn = document.getElementById("output-type-ir-btn")
                let opCBtn = document.getElementById("output-type-c-btn")
                let coOutBtn = document.getElementById("output-type-compiler-btn")

                let editor = document.getElementById("editor")
                let output = document.getElementById("output")

                let mainFileBtn = document.getElementById("main-file-btn")
                let modFileBtn = document.getElementById("mod-file-btn")

                let settingsBtn = document.getElementById("settings-btn")

                tabs[0].btnElem = mainFileBtn;
                tabs[1].btnElem = modFileBtn;

                const displayError = (text) => {
                    errorBoxMsg.innerHTML = text
                    errorBox.style.display = "block";
                    setTimeout(() => {
                        errorBox.style.display = "none";
                    }, 4000)
                }

                const getOutputButton = () => {
                    switch(outputType) {
                        case 0:
                            return opOutBtn;
                        case 1:
                            return opIrBtn;
                        case 2:
                            return opCBtn;
                        case 3:
                            return coOutBtn;
                        default:
                            console.error("1: unknown output type", outputType)
                            return null;
                    }
                }

                const getOutputText = () => {
                    switch(outputType) {
                        case 0:
                            return mainOutputText;
                        case 1:
                            return llvmIrOutputText;
                        case 2:
                            return cTranslationOutputText;
                        case 3:
                            return compilerOutputText;
                        default:
                            console.error("2: unknown output type", outputType);
                            return ""
                    }
                }

                const setOutputText = (type, text) => {
                    switch(type) {
                        case 0:
                            mainOutputText = text;
                            break;
                        case 1:
                            llvmIrOutputText = text;
                            break;
                        case 2:
                            cTranslationOutputText = text;
                            break;
                        case 3:
                            compilerOutputText = text;
                            break;
                        default:
                            console.error("3: unknown output type", outputType);
                            return;
                    }
                    if(outputType == type) {
                        output.value = text
                    }
                }
                const setOutputState = () => {
                    getOutputButton().classList.toggle("active")
                }
                const setEditorState = () => {
                    let tab = tabs[activeTab]
                    editor.value = tab.content
                    tab.btnElem.classList.toggle("active")
                }

                setOutputState()
                setEditorState()

                const onOutputBtnClick = (type) => {
                    setOutputState()
                    outputType = type;
                    setOutputState()
                    output.value = getOutputText()
                }
                const onFileBtnClick = (tabIndex) => {
                    tabs[activeTab].content = editor.value
                    tabs[activeTab].btnElem.classList.toggle("active")
                    activeTab = tabIndex
                    setEditorState()
                }
                const getContentFromEditor = () => {
                    tabs[activeTab].content = editor.value
                }

                mainFileBtn.addEventListener("click", () => { onFileBtnClick(0) })
                modFileBtn.addEventListener("click", () => { onFileBtnClick(1) })

                let fileAdderBtn = document.getElementById("file-adder-btn")
                fileAdderBtn.addEventListener("click", () => {
                    let fileName = prompt("file name:")
                    // TODO: verify the filename
                    var clonedButton = fileAdderBtn.cloneNode()
                    fileAdderBtn.parentElement.insertBefore(clonedButton, fileAdderBtn)
                    clonedButton.innerText = fileName;
                    const index = tabs.length;
                    console.log("new button index", index)
                    clonedButton.addEventListener("click", () => { onFileBtnClick(index) })
                    tabs = [...tabs, {
                        name : fileName,
                        index : index,
                        btnElem : clonedButton,
                        content : ""
                    }]
                })
                opOutBtn.addEventListener("click", () => {
                    // 0 -> output
                    onOutputBtnClick(0)
                })

                opIrBtn.addEventListener("click", () => {
                    // 1 -> llvm ir
                    onOutputBtnClick(1)
                })

                opCBtn.addEventListener("click", () => {
                    // 2 -> c translation
                    onOutputBtnClick(2)
                })

                coOutBtn.addEventListener("click", () => {
                    // 3 -> compiler output
                    onOutputBtnClick(3)
                })

                // ------------- settings setup

                // call `showSettings()` to open the dialog (e.g. hook to your Settings button)
                  function showSettings() {
                    document.getElementById('settings-modal').classList.remove('modal-hidden');
                    document.getElementById('settings-modal').setAttribute('aria-hidden','false');
                  }
                  function hideSettings() {
                    document.getElementById('settings-modal').classList.add('modal-hidden');
                    document.getElementById('settings-modal').setAttribute('aria-hidden','true');
                  }
                  // Wire up buttons (run once at page load)
                  (function(){
                    const openBtn = document.getElementById('settings-button'); // your existing settings button should have this id
                    if (openBtn) openBtn.addEventListener('click', showSettings);
                    document.getElementById('settings-close').addEventListener('click', hideSettings);
                    document.getElementById('settings-backdrop').addEventListener('click', hideSettings);
                    document.getElementById('settings-cancel').addEventListener('click', hideSettings);
                    document.getElementById('settings-save').addEventListener('click', () => {
                      // persist in-memory (you can also save to localStorage if desired)
                      window.playgroundSettings = collectSettings();
                      hideSettings();
                    });

                    // load defaults
                    window.playgroundSettings = {
                      debug_ir: false,
                      fno_unwind_tables: false,
                      mode: 'debug',
                      lto: false,
                      benchmark: false,
                      bm_files: false,
                      bm_modules: false
                    };

                    // optionally populate the form from window.playgroundSettings if you store defaults
                    function populateForm() {
                      const s = window.playgroundSettings;
                      document.getElementById('opt-debug-ir').checked = !!s.debug_ir;
                      document.getElementById('opt-fno-unwind-tables').checked = !!s.fno_unwind_tables;
                      document.getElementById('opt-mode').value = s.mode || 'debug';
                      document.getElementById('opt-lto').checked = !!s.lto;
                      document.getElementById('opt-benchmark').checked = !!s.benchmark;
                      document.getElementById('opt-bm-files').checked = !!s.bm_files;
                      document.getElementById('opt-bm-modules').checked = !!s.bm_modules;
                    }
                    populateForm();
                  })();

                  // collects the settings object to include in submit payload
                  function collectSettings() {
                    return {
                      debug_ir: document.getElementById('opt-debug-ir').checked,
                      fno_unwind_tables: document.getElementById('opt-fno-unwind-tables').checked,
                      mode: document.getElementById('opt-mode').value,
                      lto: document.getElementById('opt-lto').checked,
                      benchmark: document.getElementById('opt-benchmark').checked,
                      bm_files: document.getElementById('opt-bm-files').checked,
                      bm_modules: document.getElementById('opt-bm-modules').checked
                    };
                  }

                  settingsBtn.addEventListener("click", showSettings);

                // ------------- settings setup end -------------------------

                let submitBtn = document.getElementById("submit-btn")
                submitBtn.addEventListener("click", () => {
                    let savedOutputType = outputType
                    getContentFromEditor()
                    let input = {
                        files : [],
                        outputType : savedOutputType,
                        settings : collectSettings()
                    }
                    for(let i = 0; i < tabs.length; i++) {
                        const tab = tabs[i]
                        input.files = [...input.files, {
                            name : tab.name,
                            content : tab.content
                        }]
                    }
                    console.log("prepared input, sending", input);
                    fetch("/submit", {
                        method : "POST",
                        headers : {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(input)
                    }).then((res) => res.json()).then((res) => {
                        if(res.type == "error") {
                            displayError("error: " + res.message)
                        } else if(res.type == "output") {
                            setOutputText(savedOutputType, res.output)
                            if(res.status != 0) {
                                displayError("error: non zero status '" + res.status + "' returned, check compiler output")
                            }
                        } else {
                            displayError("error: unknown output received from server");
                        }
                    })
                })

            })
        """}</script>
        <div>
            {GlobalStyles(page)}
            {Header(page)}
            <div id="error-box" class={error_box_container(page)}>
                <div id="error-box-msg" class={error_msg_container(page)}></div>
            </div>
            <div class={textarea_container(page)}>
                <div class={editor_container(page)}>
                    <div class={editor_toolbar(page)}>
                        <select class={editor_tab_button(page)}>
                            <option>Most Basic</option>
                        </select>
                        <button id="main-file-btn" class={editor_tab_button(page)}>main.ch</button>
                        <button id="mod-file-btn" class={editor_tab_button(page)}>chemical.mod</button>
                        <button id="file-adder-btn" class={editor_tab_button(page)}>+</button>
                    </div>
                    <textarea id="editor" class={editor_area(page)}></textarea>
                </div>
                <div class={editor_container(page)}>
                    <div class={editor_toolbar(page)}>
                        <button id="output-type-output-btn" class={editor_tab_button(page)}>Output</button>
                        <button id="output-type-compiler-btn" class={editor_tab_button(page)}>CompilerOutput</button>
                        <button id="output-type-ir-btn" class={editor_tab_button(page)}>LLVM IR</button>
                        <button id="output-type-c-btn" class={editor_tab_button(page)}>C Translation</button>
                        <div class={editor_toolbar(page)} style="flex-grow:1;justify-content:end;">
                            <button class={editor_tab_button(page)} id="settings-btn">Settings</button>
                            <button id="submit-btn" class={editor_tab_button_primary(page)}>Submit</button>
                        </div>
                    </div>
                    <textarea id="output" class={display_editor(page)} placeholder="Press the submit button"></textarea>
                </div>
            </div>

            <!-- Settings modal (paste once in the page) -->
            <style>{"""
                #settings-modal.modal-hidden { display:none; }
                #settings-modal { position:fixed; inset:0; z-index:2000; }
                .modal-backdrop { position:absolute; inset:0; background:rgba(0,0,0,0.45); }
                .modal-card {
                  position:relative;
                  width:min(720px, 95%);
                  margin:6% auto;
                  background:rgb(57 57 57);
                  border-radius:8px;
                  box-shadow:0 8px 30px rgba(0,0,0,0.2);
                  padding:12px;
                }
                .modal-header { display:flex; justify-content:space-between; align-items:center; }
                .modal-body { display:flex; flex-direction:column; gap:8px; padding:8px 0; }
                .modal-footer { display:flex; justify-content:flex-end; gap:8px; padding-top:8px; }
                .modal-body label { display:flex; align-items:center; gap:8px; font-size:14px; }
            """}</style>
            <div id="settings-modal" class="modal-hidden" role="dialog" aria-modal="true" aria-hidden="true">
              <div class="modal-backdrop" id="settings-backdrop"></div>
              <div class="modal-card" role="document" id="settings-card">
                <header class="modal-header">
                  <h3>Playground Settings</h3>
                  <button id="settings-close" title="Close">✕</button>
                </header>
                <div class="modal-body">
                  <label><input type="checkbox" id="opt-debug-ir"> debug-ir (produce debug version of IR)</label>
                  <label><input type="checkbox" id="opt-fno-unwind-tables"> fno-unwind-tables (improve IR when disabled)</label>
                  <label>
                    mode
                    <select id="opt-mode">
                      <option value="debug_quick">debug_quick</option>
                      <option value="debug">debug</option>
                      <option value="debug_complete">debug_complete</option>
                      <option value="release">release</option>
                      <option value="release_fast">release_fast</option>
                      <option value="release_small">release_small</option>
                    </select>
                  </label>
                  <label><input type="checkbox" id="opt-lto"> lto (link time optimization)</label>
                  <label><input type="checkbox" id="opt-benchmark"> benchmark (benchmark compilation)</label>
                  <label><input type="checkbox" id="opt-bm-files"> bm-files (benchmark files)</label>
                  <label><input type="checkbox" id="opt-bm-modules"> bm-modules (benchmark modules)</label>
                </div>
                <footer class="modal-footer">
                  <button id="settings-cancel">Cancel</button>
                  <button id="settings-save">Save</button>
                </footer>
              </div>
            </div>

            {Footer(page)}
        </div>
    }
}