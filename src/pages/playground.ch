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
        background-color : rgba(255, 0, 0, 0.1);
        border : 1px solid rgba(255, 0, 0, 0.3);
        color : #fca5a5;
    }
}

func textarea_container(page : &mut HtmlPage) : *char {
    return #css {
        display : flex;
        flex-direction:row;
        width : 100%;
        padding : 1em;
        gap : 1em;
        flex-wrap: wrap;
    }
}

func editor_area(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        height : 100%;
        min-height : 80vh;
        background-color : var(--surface);
        outline : 0;
        border : 1px solid var(--border-color);
        border-bottom-left-radius : 8px;
        border-bottom-right-radius : 8px;
        overflow: hidden;
    }
}

func display_editor(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        height : 100%;
        min-height : 80vh;
        background-color : var(--bg);
        outline : 0;
        border : 1px solid var(--border-color);
        border-bottom-left-radius : 8px;
        border-bottom-right-radius : 8px;
        overflow: hidden;
    }
}

func editor_container(page : &mut HtmlPage) : *char {
    return #css {
        display : flex;
        flex-direction : column;
        flex : 1;
        min-width: 0;
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
        padding : 10px 18px;
        background-color : transparent;
        border-top-left-radius : 6px;
        border-top-right-radius : 6px;
        border : 1px solid transparent;
        color : var(--text-muted);
        cursor: pointer;
        font-size: 13px;
        font-weight: 500;
        transition: all 0.2s;
    }
}

func tab_select_opt(page : &mut HtmlPage) : *char {
    return #css {
        padding : 8px 12px;
        background-color : var(--surface);
        color : var(--text);
    }
}

func editor_tab_button_primary(page : &mut HtmlPage) : *char {
    return #css {
        padding : 8px 16px;
        background-color : var(--accent-primary);
        border-radius : 4px;
        border : 0;
        color : var(--accent-contrast);
        font-weight: 600;
        cursor: pointer;
        font-size: 13px;
    }
}

func PlaygroundPage(page : &mut HtmlPage) {
    var strListMapCompSet = getStrListMapCompSet()
    var exprStrCompSet = getExprStrCompSet()
    var embeddedLangsCompSet = getEmbeddedLangsCompSet()
    #html {
        <style>{"""
            button.active {
                background-color : var(--surface);
                color: var(--text);
                border: 1px solid var(--border-color);
                border-bottom: 1px solid var(--surface);
                margin-bottom: -1px;
                z-index: 10;
                font-weight: 600;
            }
        """}</style>
        <script>{"""
        function create_tabs_from_comp_set(main, mod) {
            return [
                {
                    name : "main.ch",
                    index : 0,
                    btnElem : null,
                    content : main.replace(/\\`/g, '`')
                },
                {
                    name : "chemical.mod",
                    index : 1,
                    btnElem : null,
                    content : mod.replace(/\\`/g, '`')
                }
            ]
        }
        """}</script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/loader.min.js"></script>
        <script>{"""
        require.config({ paths: { 'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs' }});
        """}</script>
        <script>window.strListMapTabs = create_tabs_from_comp_set(`{strListMapCompSet.main}`, `{strListMapCompSet.mod}`)</script>
        <script>window.exprStrTabs = create_tabs_from_comp_set(`{exprStrCompSet.main}`, `{exprStrCompSet.mod}`)</script>
        <script>window.embeddedLangsTabs = create_tabs_from_comp_set(`{embeddedLangsCompSet.main}`, `{embeddedLangsCompSet.mod}`)</script>
        <script>{"""

            window.mostBasicTabs = create_tabs_from_comp_set(`@extern
public func printf(format : *char, _ : any...)
public func main() : int {
    printf("Hello World");
    return 0;
}`, `module main
source "main.ch"
`)

            // 0 -> output, 1 -> llvm ir, 2 -> c translation, 4 -> compiler output
            let outputType = 0;
            let tabs = window.mostBasicTabs
            let activeTab = 0

            let mainOutputText = ""
            let llvmIrOutputText = ""
            let cTranslationOutputText = ""
            let compilerOutputText = ""
            let assemblyOutputText = ""

            let inputEditor = null;
            let outputEditor = null;

            // Settings Logic
            const showSettings = () => {
                document.getElementById('settings-modal').classList.remove('modal-hidden');
            }
            
            const hideSettings = () => {
                document.getElementById('settings-modal').classList.add('modal-hidden');
            }

            const collectSettings = () => {
                return {
                    verbose: document.getElementById('opt-verbose').checked,
                    use_tcc: document.getElementById('opt-use-tcc').checked,
                    debug_ir: document.getElementById('opt-debug-ir').checked,
                    fno_unwind_tables: document.getElementById('opt-fno-unwind-tables').checked,
                    mode: document.getElementById('opt-mode').value,
                    lto: document.getElementById('opt-lto').checked,
                    benchmark: document.getElementById('opt-benchmark').checked,
                    bm_files: document.getElementById('opt-bm-files').checked,
                    bm_modules: document.getElementById('opt-bm-modules').checked
                };
            }

            document.addEventListener("DOMContentLoaded", () => {

                let errorBox = document.getElementById("error-box")
                let errorBoxMsg = document.getElementById("error-box-msg")

                let opOutBtn = document.getElementById("output-type-output-btn")
                let opIrBtn = document.getElementById("output-type-ir-btn")
                let opCBtn = document.getElementById("output-type-c-btn")
                let coOutBtn = document.getElementById("output-type-compiler-btn")
                let opAsmBtn = document.getElementById("output-type-asm-btn")

                let mainFileBtn = document.getElementById("main-file-btn")
                let modFileBtn = document.getElementById("mod-file-btn")

                let settingsBtn = document.getElementById("settings-btn")
                let submitBtn = document.getElementById("submit-btn")

                tabs[0].btnElem = mainFileBtn;
                tabs[1].btnElem = modFileBtn;

                // --- Helper Functions ---

                const displayError = (text) => {
                    errorBoxMsg.innerHTML = text
                    errorBox.style.display = "block";
                    setTimeout(() => {
                        errorBox.style.display = "none";
                    }, 4000)
                }

                const getOutputButton = () => {
                    switch(outputType) {
                        case 0: return opOutBtn;
                        case 1: return opIrBtn;
                        case 2: return opCBtn;
                        case 3: return coOutBtn;
                        case 4: return opAsmBtn;
                        default: return null;
                    }
                }

                const getOutputText = () => {
                    switch(outputType) {
                        case 0: return mainOutputText;
                        case 1: return llvmIrOutputText;
                        case 2: return cTranslationOutputText;
                        case 3: return compilerOutputText;
                        case 4: return assemblyOutputText;
                        default: return ""
                    }
                }

                const setOutputText = (type, text) => {
                    switch(type) {
                        case 0: mainOutputText = text; break;
                        case 1: llvmIrOutputText = text; break;
                        case 2: cTranslationOutputText = text; break;
                        case 3: compilerOutputText = text; break;
                        case 4: assemblyOutputText = text; break;
                        default: return;
                    }
                    if(outputType == type && outputEditor) {
                        outputEditor.setValue(text);
                    }
                }

                const setOutputState = () => {
                    let btn = getOutputButton();
                    if(btn) btn.classList.toggle("active")
                }

                const setEditorState = () => {
                    let tab = tabs[activeTab]
                    if(inputEditor) inputEditor.setValue(tab.content)
                    if(tab.btnElem) tab.btnElem.classList.toggle("active")
                }
                
                const getContentFromEditor = () => {
                    if(inputEditor) tabs[activeTab].content = inputEditor.getValue()
                }

                // --- Event Listeners ---

                const onOutputBtnClick = (type) => {
                    setOutputState()
                    outputType = type;
                    setOutputState()
                    if(outputEditor) {
                        const text = getOutputText();
                        outputEditor.setValue(text);
                        
                        let lang = 'cpp';
                        if (type === 0 || type === 1 || type === 3) lang = 'plaintext';
                        if (type === 4) lang = 'mips';
                        monaco.editor.setModelLanguage(outputEditor.getModel(), lang);
                    }
                }

                const onFileBtnClick = (tabIndex) => {
                    getContentFromEditor()
                    tabs[activeTab].btnElem.classList.toggle("active")
                    activeTab = tabIndex
                    setEditorState()
                }

                function setTabs(newTabs) {
                    tabs = newTabs
                    tabs[0].btnElem = mainFileBtn
                    tabs[1].btnElem = modFileBtn;
                    activeTab = 0
                    if(inputEditor) inputEditor.setValue(tabs[0].content)
                    
                    mainFileBtn.classList.remove("active");
                    modFileBtn.classList.remove("active");
                    tabs[0].btnElem.classList.add("active");
                }

                const select = document.getElementById('examples');
                select.addEventListener('change', () => {
                    const val = select.value;
                    switch (val) {
                        case '1': setTabs(window.mostBasicTabs); break;
                        case '2': setTabs(window.strListMapTabs); break;
                        case '3': setTabs(window.exprStrTabs); break;
                        case '4': setTabs(window.embeddedLangsTabs); break;
                    }
                });

                mainFileBtn.addEventListener("click", () => { onFileBtnClick(0) })
                modFileBtn.addEventListener("click", () => { onFileBtnClick(1) })

                let fileAdderBtn = document.getElementById("file-adder-btn")
                fileAdderBtn.addEventListener("click", () => {
                    let fileName = prompt("file name:")
                    if(!fileName) return;
                    var clonedButton = fileAdderBtn.cloneNode()
                    fileAdderBtn.parentElement.insertBefore(clonedButton, fileAdderBtn)
                    clonedButton.innerText = fileName;
                    const index = tabs.length;
                    clonedButton.addEventListener("click", () => { onFileBtnClick(index) })
                    tabs = [...tabs, {
                        name : fileName,
                        index : index,
                        btnElem : clonedButton,
                        content : ""
                    }]
                })

                opOutBtn.addEventListener("click", () => { onOutputBtnClick(0) })
                opIrBtn.addEventListener("click", () => { onOutputBtnClick(1) })
                opCBtn.addEventListener("click", () => { onOutputBtnClick(2) })
                coOutBtn.addEventListener("click", () => { onOutputBtnClick(3) })
                opAsmBtn.addEventListener("click", () => { onOutputBtnClick(4) })

                // Settings
                if(settingsBtn) settingsBtn.addEventListener("click", showSettings);
                document.getElementById('settings-close').addEventListener('click', hideSettings);
                document.getElementById('settings-cancel').addEventListener('click', hideSettings);
                document.getElementById('settings-save').addEventListener('click', hideSettings);
                document.getElementById('settings-backdrop').addEventListener('click', hideSettings);

                // Submit
                let submitBtnText = submitBtn.innerText;
                const setLoading = (isLoading) => {
                    if(isLoading) {
                        submitBtn.disabled = true;
                        submitBtn.innerHTML = '<span class="spinner"></span> Processing...';
                    } else {
                        submitBtn.disabled = false;
                        submitBtn.innerText = submitBtnText;
                    }
                }

                submitBtn.addEventListener("click", () => {
                    if(!inputEditor) {
                        console.error("Editor not initialized");
                        return;
                    }
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
                    
                    setLoading(true);
                    
                    fetch("/submit", {
                        method : "POST",
                        headers : { 'Content-Type': 'application/json' },
                        body: JSON.stringify(input)
                    }).then((res) => res.json()).then((res) => {
                        setLoading(false);
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
                    }).catch((err) => {
                        setLoading(false);
                        displayError("error: network or server error");
                        console.error(err);
                    })
                })

                // --- Monaco Initialization ---

                require(['vs/editor/editor.main'], function () {
                    
                    let editorContainer = document.getElementById("editor-container")
                    let outputContainer = document.getElementById("output-container")

                    const updateTheme = () => {
                        const isLight = document.body.classList.contains('light-theme');
                        const isDark = !isLight;
                        const style = getComputedStyle(document.body)
                        
                        // Read CSS variables
                        const bg = style.getPropertyValue('--bg').trim() || (isDark ? '#1e1e1e' : '#ffffff');
                        const surface = style.getPropertyValue('--surface').trim() || (isDark ? '#252526' : '#f3f3f3');
                        const text = style.getPropertyValue('--text').trim() || (isDark ? '#d4d4d4' : '#000000');
                        const border = style.getPropertyValue('--border-color').trim();

                        monaco.editor.defineTheme('chemical-theme', {
                            base: isDark ? 'vs-dark' : 'vs',
                            inherit: true,
                            rules: [
                                { background: bg.replace('#', '') }
                            ],
                            colors: {
                                'editor.background': bg,
                                'editor.foreground': text,
                                'editor.lineHighlightBackground': surface,
                                'editor.selectionBackground': surface,
                                'editor.inactiveSelectionBackground': surface,
                            }
                        });
                        monaco.editor.setTheme('chemical-theme');
                    };

                    updateTheme();

                    inputEditor = monaco.editor.create(editorContainer, {
                        value: tabs[0].content,
                        language: 'rust',
                        theme: 'chemical-theme',
                        automaticLayout: true,
                        minimap: { enabled: false },
                        scrollBeyondLastLine: false,
                        fontSize: 14,
                        fontFamily: "'Menlo', 'Monaco', 'Courier New', monospace"
                    });

                    outputEditor = monaco.editor.create(outputContainer, {
                        value: "",
                        language: 'plaintext',
                        theme: 'chemical-theme',
                        readOnly: true,
                        automaticLayout: true,
                        minimap: { enabled: false },
                        scrollBeyondLastLine: false,
                        fontSize: 14,
                        fontFamily: "'Menlo', 'Monaco', 'Courier New', monospace"
                    });

                    // Observer for theme changes
                    const observer = new MutationObserver((mutations) => {
                        updateTheme();
                    });
                    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class', 'style'] });
                    observer.observe(document.body, { attributes: true, attributeFilter: ['class', 'style'] });

                    // Initial button state
                    tabs[activeTab].btnElem.classList.add("active")
                    setOutputState()

                }); // End require
            })
        """}</script>
        <div>
            {GlobalStyles(page)}
            {Header(page)}
            <div id="error-box" class={error_box_container(page)}>
                <div id="error-box-msg" class={error_msg_container(page)}></div>
            </div>
            <div class={textarea_container(page)}>
                <style>{"""
                    @media (max-width: 768px) {
                        ."""}{textarea_container(page)}{""" {
                            flex-direction: column;
                        }
                        ."""}{editor_container(page)}{""" {
                            min-height: 50vh;
                        }
                    }
                """}</style>
                <div class={editor_container(page)}>
                    <div class={editor_toolbar(page)}>
                        <select id="examples" class={editor_tab_button(page)}>
                            <option value="1" class={tab_select_opt(page)}>Most Basic</option>
                            <option value="2" class={tab_select_opt(page)}>String List</option>
                            <option value="3" class={tab_select_opt(page)}>Expressive Strings</option>
                            <option value="4" class={tab_select_opt(page)}>Embedded Languages</option>
                        </select>
                        <button id="main-file-btn" class={editor_tab_button(page)}>main.ch</button>
                        <button id="mod-file-btn" class={editor_tab_button(page)}>chemical.mod</button>
                        <button id="file-adder-btn" class={editor_tab_button(page)}>+</button>
                    </div>
                    <div id="editor-container" class={editor_area(page)}></div>
                </div>
                <div class={editor_container(page)}>
                    <div class={editor_toolbar(page)}>
                        <button id="output-type-output-btn" class={editor_tab_button(page)}>Output</button>
                        <button id="output-type-compiler-btn" class={editor_tab_button(page)}>CompilerOutput</button>
                        <button id="output-type-ir-btn" class={editor_tab_button(page)}>LLVM IR</button>
                        <button id="output-type-asm-btn" class={editor_tab_button(page)}>Assembly</button>
                        <button id="output-type-c-btn" class={editor_tab_button(page)}>C Translation</button>
                        <div class={editor_toolbar(page)} style="flex-grow:1;justify-content:end;">
                            <button class={editor_tab_button(page)} id="settings-btn">Settings</button>
                            <button id="submit-btn" class={editor_tab_button_primary(page)}>Submit</button>
                        </div>
                    </div>
                    <div id="output-container" class={display_editor(page)}></div>
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
                  background:var(--surface);
                  border: 1px solid var(--border-color);
                  border-radius:8px;
                  box-shadow:0 8px 30px rgba(0,0,0,0.2);
                  padding:12px;
                }
                .modal-header { display:flex; justify-content:space-between; align-items:center; margin-bottom: 1rem; }
                .modal-body { display:flex; flex-direction:column; gap:12px; padding:8px 0; }
                .modal-footer { display:flex; justify-content:flex-end; gap:12px; padding-top:16px; border-top: 1px solid var(--border-color); margin-top: 16px; }
                .modal-body label { display:flex; align-items:center; gap:12px; font-size:15px; color: var(--text); cursor: pointer; }
                .modal-body input[type="checkbox"] { accent-color: var(--accent-primary); width: 16px; height: 16px; }
                .modal-body select { 
                    padding: 6px 12px; 
                    border-radius: var(--border-radius); 
                    border: 1px solid var(--border-color); 
                    background: var(--bg); 
                    color: var(--text); 
                }
                #settings-close {
                    background: transparent;
                    border: none;
                    color: var(--text-muted);
                    font-size: 1.5rem;
                    cursor: pointer;
                    padding: 4px;
                    line-height: 1;
                    border-radius: 4px;
                    transition: all 0.2s;
                }
                #settings-close:hover {
                    color: var(--text);
                    background: var(--muted-surface);
                }
            """}</style>
            <div id="settings-modal" class="modal-hidden" role="dialog" aria-modal="true" aria-hidden="true">
              <div class="modal-backdrop" id="settings-backdrop"></div>
              <div class="modal-card" role="document" id="settings-card">
                <div class="modal-header">
                  <h3>Playground Settings</h3>
                  <button id="settings-close" title="Close">✕</button>
                </div>
                <div class="modal-body">
                  <label><input type="checkbox" id="opt-verbose"> verbose (more logs)</label>
                  <label><input type="checkbox" id="opt-use-tcc" checked> use-tcc (run translated c code via tiny cc)</label>
                  <label><input type="checkbox" id="opt-debug-ir"> debug-ir (produce debug version of IR)</label>
                  <label><input type="checkbox" id="opt-fno-unwind-tables"> fno-unwind-tables (readable IR)</label>
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
                <div class="modal-footer">
                  <button id="settings-cancel" class="btn btn-secondary">Cancel</button>
                  <button id="settings-save" class="btn btn-primary">Save Changes</button>
                </div>
              </div>
            </div>

            {Footer(page)}
        </div>
    }
}