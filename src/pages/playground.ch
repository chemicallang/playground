func error_box_container(page : &mut HtmlPage) : *char {
    return #css {
        position : fixed;
        top : 76px;
        left : 50%;
        transform : translateX(-50%);
        width : min(560px, calc(100vw - 40px));
        z-index : 3000;
        display : none;
        animation : toast-in 0.25s cubic-bezier(0.22, 1, 0.36, 1);
    }
}

func error_msg_container(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        padding : 12px 16px;
        border-radius : 6px;
        background-color : var(--bg-elevated);
        border : 1px solid var(--err);
        color : var(--err);
        font-family : var(--font-mono);
        font-size : 13px;
        line-height : 1.5;
        box-shadow : 0 12px 32px -12px rgba(0, 0, 0, 0.6);
    }
}

func textarea_container(page : &mut HtmlPage) : *char {
    return #css {
        display : flex;
        flex-direction : row;
        width : 100%;
        max-width : 1600px;
        margin : 0 auto;
        padding : 16px 20px 20px;
        gap : 16px;
        flex-wrap : nowrap;
    }
}

func editor_area(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        height : 100%;
        min-height : 72vh;
        background-color : var(--bg-inset);
        outline : 0;
        border : 1px solid var(--line);
        border-top : 0;
        border-bottom-left-radius : 8px;
        border-bottom-right-radius : 8px;
        overflow : hidden;
    }
}

func display_editor(page : &mut HtmlPage) : *char {
    return #css {
        width : 100%;
        height : 100%;
        min-height : 72vh;
        background-color : var(--bg-inset);
        outline : 0;
        border : 1px solid var(--line);
        border-top : 0;
        border-bottom-left-radius : 8px;
        border-bottom-right-radius : 8px;
        overflow : hidden;
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
        align-items : center;
        gap : 2px;
        padding : 6px 8px;
        background-color : var(--bg-elevated);
        border : 1px solid var(--line);
        border-radius : 8px 8px 0 0;
    }
}

func editor_tab_button(page : &mut HtmlPage) : *char {
    return #css {
        padding : 7px 12px;
        background-color : transparent;
        border-radius : 5px;
        border : 1px solid transparent;
        color : var(--text-dim);
        cursor : pointer;
        font-family : var(--font-mono);
        font-size : 12px;
        font-weight : 500;
        transition : color 0.15s, background-color 0.15s;
    }
}

func tab_select_opt(page : &mut HtmlPage) : *char {
    return #css {
        padding : 7px 12px;
        background-color : var(--bg-elevated);
        color : var(--text);
    }
}

func editor_tab_button_primary(page : &mut HtmlPage) : *char {
    return #css {
        padding : 7px 18px;
        background-color : var(--accent);
        border-radius : 5px;
        border : 0;
        color : var(--accent-ink);
        font-weight : 600;
        cursor : pointer;
        font-family : var(--font-sans);
        font-size : 12.5px;
        transition : filter 0.15s;
    }
}

func PlaygroundPage(page : &mut HtmlPage) {
    var strListMapCompSet = getStrListMapCompSet()
    var exprStrCompSet = getExprStrCompSet()
    var embeddedLangsCompSet = getEmbeddedLangsCompSet()
    var componentsCompSet = getComponentsCompSet()
    #html {
        <style>{"""
            button.active {
                background-color : var(--accent-dim);
                color: var(--accent);
            }
            
            /* pane headers */
            .pane-title {
                font-family: var(--font-mono);
                font-size: 0.68rem;
                letter-spacing: 0.12em;
                text-transform: uppercase;
                color: var(--text-dim);
                margin-right: 10px;
                padding-left: 6px;
                user-select: none;
            }
            .toolbar-sep {
                width: 1px;
                height: 18px;
                background: var(--line-strong);
                margin: 0 8px;
                flex-shrink: 0;
            }
            #submit-btn:hover { filter: brightness(1.08); }
            #submit-btn:disabled { opacity: 0.6; cursor: default; }
            .spinner {
                display: inline-block;
                width: 12px; height: 12px;
                border: 2px solid var(--accent-ink);
                border-top-color: transparent;
                border-radius: 50%;
                animation: spin 0.7s linear infinite;
                vertical-align: -2px;
            }
            @keyframes spin { to { transform: rotate(360deg); } }
            @keyframes toast-in {
                from { opacity: 0; transform: translateX(-50%) translateY(-8px); }
                to { opacity: 1; transform: translateX(-50%) translateY(0); }
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
        <script>window.componentTabs = create_tabs_from_comp_set(`{componentsCompSet.main}`, `{componentsCompSet.mod}`)</script>
<script>window.fileopsTabs = create_tabs_from_comp_set(`{getFileopsSet().main}`, `{getFileopsSet().mod}`)</script>
<script>window.timetellerTabs = create_tabs_from_comp_set(`{getTimetellerSet().main}`, `{getTimetellerSet().mod}`)</script>
<script>window.jsnTabs = create_tabs_from_comp_set(`{getJsnSet().main}`, `{getJsnSet().mod}`)</script>
<script>window.uuidgenTabs = create_tabs_from_comp_set(`{getUuidgenSet().main}`, `{getUuidgenSet().mod}`)</script>
<script>window.hashpassTabs = create_tabs_from_comp_set(`{getHashpassSet().main}`, `{getHashpassSet().mod}`)</script>
<script>window.fetchrTabs = create_tabs_from_comp_set(`{getFetchrSet().main}`, `{getFetchrSet().mod}`)</script>
<script>window.envbeeTabs = create_tabs_from_comp_set(`{getEnvbeeSet().main}`, `{getEnvbeeSet().mod}`)</script>
<script>window.runprocTabs = create_tabs_from_comp_set(`{getRunprocSet().main}`, `{getRunprocSet().mod}`)</script>
<script>window.pathwaysTabs = create_tabs_from_comp_set(`{getPathwaysSet().main}`, `{getPathwaysSet().mod}`)</script>
<script>window.digestTabs = create_tabs_from_comp_set(`{getDigestSet().main}`, `{getDigestSet().mod}`)</script>
<script>window.shrinkitTabs = create_tabs_from_comp_set(`{getShrinkitSet().main}`, `{getShrinkitSet().mod}`)</script>
<script>window.hexitTabs = create_tabs_from_comp_set(`{getHexitSet().main}`, `{getHexitSet().mod}`)</script>
<script>window.docsmithTabs = create_tabs_from_comp_set(`{getDocsmithSet().main}`, `{getDocsmithSet().mod}`)</script>
        <script>{"""

            window.mostBasicTabs = create_tabs_from_comp_set(`@extern
public func printf(format : *char, _ : any...)
public func main() : int {
    printf("Hello World");
    return 0;
}`, `application main
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
                    bm_modules: document.getElementById('opt-bm-modules').checked,
                    version: document.getElementById('opt-version').value,
                    process_commands: document.getElementById('opt-process-commands').checked
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
                let webviewBtn = document.getElementById("output-type-webview-btn")

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
                        case 5: return webviewBtn;
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
                    
                    let outputContainerDOM = document.getElementById("output-container")
                    let webviewFrameDOM = document.getElementById("webview-frame")

                    if (type === 5) {
                        outputContainerDOM.style.display = "none"
                        webviewFrameDOM.style.display = "block"
                    } else {
                        outputContainerDOM.style.display = "block"
                        webviewFrameDOM.style.display = "none"
                    }

                    if(outputEditor && type !== 5) {
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
                        case '5': setTabs(window.componentTabs); break;
                        case '6': setTabs(window.fileopsTabs); break;
                        case '7': setTabs(window.timetellerTabs); break;
                        case '8': setTabs(window.jsnTabs); break;
                        case '9': setTabs(window.uuidgenTabs); break;
                        case '10': setTabs(window.hashpassTabs); break;
                        case '11': setTabs(window.fetchrTabs); break;
                        case '12': setTabs(window.envbeeTabs); break;
                        case '13': setTabs(window.runprocTabs); break;
                        case '14': setTabs(window.pathwaysTabs); break;
                        case '15': setTabs(window.digestTabs); break;
                        case '16': setTabs(window.shrinkitTabs); break;
                        case '17': setTabs(window.hexitTabs); break;
                        case '18': setTabs(window.docsmithTabs); break;
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
                webviewBtn.addEventListener("click", () => { onOutputBtnClick(5) })

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
                    let savedOutputType = outputType === 5 ? 0 : outputType
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

                            if (savedOutputType === 0 && input.settings.process_commands && res.output.startsWith("%!webview:")) {
                                let htmlContent = res.output.substring(10)
                                let webviewFrameDOM = document.getElementById("webview-frame")
                                webviewFrameDOM.srcdoc = htmlContent
                                webviewBtn.style.display = "block"
                                onOutputBtnClick(5)
                            } else {
                                webviewBtn.style.display = "none"
                                if(outputType == 5) {
                                    onOutputBtnClick(savedOutputType)
                                }
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
                                'editor.background': isDark ? '#060608' : '#F1F1EC',
                                'editor.foreground': isDark ? '#E8E8EC' : '#17171C',
                                'editor.lineHighlightBackground': isDark ? '#101014' : '#E9E9E2',
                                'editor.selectionBackground': isDark ? '#2A2A32' : '#D9D9CE',
                                'editor.inactiveSelectionBackground': isDark ? '#1D1D23' : '#E4E4DD',
                                'editorLineNumber.foreground': isDark ? '#3A3A44' : '#B8B8AE',
                                'editorLineNumber.activeForeground': isDark ? '#4DA3FF' : '#1D5FBF',
                                'editorCursor.foreground': isDark ? '#4DA3FF' : '#1D5FBF',
                                'editorIndentGuide.background1': isDark ? '#1D1D23' : '#E4E4DD',
                                'editorWidget.background': isDark ? '#101014' : '#FFFFFF',
                                'editorWidget.border': isDark ? '#2A2A32' : '#D4D4CB',
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
                        fontSize: 13.5,
                        fontFamily: "'IBM Plex Mono', ui-monospace, 'Menlo', monospace",
                        renderLineHighlight: 'line',
                        smoothScrolling: true,
                        padding: { top: 14, bottom: 14 }
                    });

                    outputEditor = monaco.editor.create(outputContainer, {
                        value: "",
                        language: 'plaintext',
                        theme: 'chemical-theme',
                        readOnly: true,
                        automaticLayout: true,
                        minimap: { enabled: false },
                        scrollBeyondLastLine: false,
                        fontSize: 13.5,
                        fontFamily: "'IBM Plex Mono', ui-monospace, 'Menlo', monospace",
                        renderLineHighlight: 'none',
                        smoothScrolling: true,
                        padding: { top: 14, bottom: 14 }
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
                        <span class="pane-title">Editor</span>
                        <select id="examples" class={editor_tab_button(page)} title="Load an example">
                            <option value="1" class={tab_select_opt(page)}>Most Basic</option>
                            <option value="2" class={tab_select_opt(page)}>String List</option>
                            <option value="3" class={tab_select_opt(page)}>Expressive Strings</option>
                            <option value="4" class={tab_select_opt(page)}>Embedded Languages</option>
                            <option value="5" class={tab_select_opt(page)}>Component Frameworks</option>
                            <option value="6" class={tab_select_opt(page)}>File System</option>
                            <option value="7" class={tab_select_opt(page)}>Date & Time</option>
                            <option value="8" class={tab_select_opt(page)}>JSON</option>
                            <option value="9" class={tab_select_opt(page)}>UUID</option>
                            <option value="10" class={tab_select_opt(page)}>Bcrypt</option>
                            <option value="11" class={tab_select_opt(page)}>HTTP Client</option>
                            <option value="12" class={tab_select_opt(page)}>Environment</option>
                            <option value="13" class={tab_select_opt(page)}>Process</option>
                            <option value="14" class={tab_select_opt(page)}>Paths</option>
                            <option value="15" class={tab_select_opt(page)}>Crypto</option>
                            <option value="16" class={tab_select_opt(page)}>Compression</option>
                            <option value="17" class={tab_select_opt(page)}>Encoding</option>
                            <option value="18" class={tab_select_opt(page)}>DocGen</option>
                        </select>
                        <span class="toolbar-sep"></span>
                        <button id="main-file-btn" class={editor_tab_button(page)}>main.ch</button>
                        <button id="mod-file-btn" class={editor_tab_button(page)}>chemical.mod</button>
                        <button id="file-adder-btn" class={editor_tab_button(page)} title="Add file">+</button>
                    </div>
                    <div id="editor-container" class={editor_area(page)}></div>
                </div>
                <div class={editor_container(page)}>
                    <div class={editor_toolbar(page)}>
                        <span class="pane-title">Output</span>
                        <button id="output-type-output-btn" class={editor_tab_button(page)}>Output</button>
                        <button id="output-type-compiler-btn" class={editor_tab_button(page)}>Compiler</button>
                        <button id="output-type-ir-btn" class={editor_tab_button(page)}>LLVM IR</button>
                        <button id="output-type-asm-btn" class={editor_tab_button(page)}>ASM</button>
                        <button id="output-type-c-btn" class={editor_tab_button(page)}>C</button>
                        <button id="output-type-webview-btn" class={editor_tab_button(page)} style="display:none">WebView</button>
                        <div class={editor_toolbar(page)} style="flex-grow:1;justify-content:end;background:transparent;border:none;padding:0;">
                            <button class={editor_tab_button(page)} id="settings-btn">Settings</button>
                            <button id="submit-btn" class={editor_tab_button_primary(page)}>Run &#8594;</button>
                        </div>
                    </div>
                    <div id="output-container" class={display_editor(page)}></div>
                    <iframe id="webview-frame" class={display_editor(page)} style="display:none; border:none; background:white;"></iframe>
                </div>
            </div>

            <!-- Settings modal -->
            <style>{"""
                #settings-modal.modal-hidden { display:none; }
                #settings-modal { position:fixed; inset:0; z-index:2000; }
                .modal-backdrop { position:absolute; inset:0; background:rgba(0,0,0,0.6); backdrop-filter: blur(4px); }
                .modal-card {
                  position:relative;
                  width:min(560px, calc(100% - 32px));
                  margin:7vh auto;
                  max-height:82vh;
                  overflow-y:auto;
                  background:var(--bg-elevated);
                  border: 1px solid var(--line-strong);
                  border-radius:10px;
                  box-shadow:0 32px 80px -24px rgba(0,0,0,0.7);
                  padding:24px;
                }
                .modal-header { display:flex; justify-content:space-between; align-items:center; margin-bottom: 20px; }
                .modal-header h3 { font-size: 1.05rem; font-weight: 600; }
                .modal-body { display:flex; flex-direction:column; gap:10px; }
                .modal-footer { display:flex; justify-content:flex-end; gap:10px; padding-top:18px; border-top: 1px solid var(--line); margin-top: 18px; }
                .modal-body label { 
                    display:flex; align-items:center; justify-content: space-between; gap:14px; 
                    font-size:13.5px; color: var(--text-secondary); cursor: pointer;
                    padding: 9px 12px;
                    border: 1px solid var(--line);
                    border-radius: 6px;
                    transition: border-color 0.15s, background-color 0.15s;
                }
                .modal-body label:hover { border-color: var(--line-strong); background: var(--bg-inset); }
                .modal-body label > input[type="checkbox"] { accent-color: var(--accent); width: 15px; height: 15px; flex-shrink: 0; }
                .modal-body .opt-row {
                    display:flex; align-items:center; justify-content: space-between; gap:14px;
                    padding: 9px 12px;
                    border: 1px solid var(--line);
                    border-radius: 6px;
                }
                .modal-body .opt-row > select { 
                    padding: 5px 10px; 
                    border-radius: 5px; 
                    border: 1px solid var(--line-strong); 
                    background: var(--bg-inset); 
                    color: var(--text);
                    font-family: var(--font-mono);
                    font-size: 12.5px;
                }
                .modal-body .opt-name { font-family: var(--font-mono); font-size: 12.5px; color: var(--text); }
                #settings-close {
                    background: transparent;
                    border: none;
                    color: var(--text-dim);
                    font-size: 1.2rem;
                    cursor: pointer;
                    padding: 6px 10px;
                    line-height: 1;
                    border-radius: 5px;
                    transition: all 0.2s;
                }
                #settings-close:hover {
                    color: var(--text);
                    background: var(--bg-inset);
                }
            """}</style>
            <div id="settings-modal" class="modal-hidden" role="dialog" aria-modal="true" aria-hidden="true">
              <div class="modal-backdrop" id="settings-backdrop"></div>
              <div class="modal-card" role="document" id="settings-card">
                <div class="modal-header">
                  <h3>Settings</h3>
                  <button id="settings-close" title="Close">&#10005;</button>
                </div>
                <div class="modal-body">
                  <div class="opt-row">
                    <span class="opt-name">compiler version</span>
                    <select id="opt-version">
{version_options_html()}
                    </select>
                  </div>
                  <div class="opt-row">
                    <span class="opt-name">mode</span>
                    <select id="opt-mode">
                      <option value="debug_quick">debug_quick</option>
                      <option value="debug">debug</option>
                      <option value="debug_complete">debug_complete</option>
                      <option value="release">release</option>
                      <option value="release_fast">release_fast</option>
                      <option value="release_small">release_small</option>
                    </select>
                  </div>
                  <label><span class="opt-name">verbose</span><input type="checkbox" id="opt-verbose"></label>
                  <label><span class="opt-name">use-tcc &mdash; run translated c via tiny cc</span><input type="checkbox" id="opt-use-tcc" checked></label>
                  <label><span class="opt-name">debug-ir &mdash; produce debug version of ir</span><input type="checkbox" id="opt-debug-ir"></label>
                  <label><span class="opt-name">fno-unwind-tables &mdash; readable ir</span><input type="checkbox" id="opt-fno-unwind-tables"></label>
                  <label><span class="opt-name">lto &mdash; link time optimization</span><input type="checkbox" id="opt-lto"></label>
                  <label><span class="opt-name">benchmark &mdash; benchmark compilation</span><input type="checkbox" id="opt-benchmark"></label>
                  <label><span class="opt-name">bm-files &mdash; benchmark files</span><input type="checkbox" id="opt-bm-files"></label>
                  <label><span class="opt-name">bm-modules &mdash; benchmark modules</span><input type="checkbox" id="opt-bm-modules"></label>
                  <label><span class="opt-name">process commands</span><input type="checkbox" id="opt-process-commands" checked></label>
                </div>
                <div class="modal-footer">
                  <button id="settings-cancel" class="btn btn-ghost btn-sm">Cancel</button>
                  <button id="settings-save" class="btn btn-primary btn-sm">Save</button>
                </div>
              </div>
            </div>

            {Footer(page)}
        </div>
    }
}