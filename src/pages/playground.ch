import "@html/page.ch"

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

                let opOutBtn = document.getElementById("output-type-output-btn")
                let opIrBtn = document.getElementById("output-type-ir-btn")
                let opCBtn = document.getElementById("output-type-c-btn")
                let coOutBtn = document.getElementById("output-type-compiler-btn")

                let editor = document.getElementById("editor")
                let output = document.getElementById("output")

                let mainFileBtn = document.getElementById("main-file-btn")
                let modFileBtn = document.getElementById("mod-file-btn")

                tabs[0].btnElem = mainFileBtn;
                tabs[1].btnElem = modFileBtn;

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

                let submitBtn = document.getElementById("submit-btn")
                submitBtn.addEventListener("click", () => {
                    let savedOutputType = outputType
                    getContentFromEditor()
                    let input = { files : [], outputType : savedOutputType }
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
                            console.log(res)
                        } else if(res.type == "output") {
                            setOutputText(savedOutputType, res.output)
                            // console.log("received output", res.output);
                        } else {
                            console.error("unknown", res);
                        }
                    })
                })

            })
        """}</script>
        <div>
            {GlobalStyles(page)}
            {Header(page)}

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
                            <button class={editor_tab_button(page)}>Settings</button>
                            <button id="submit-btn" class={editor_tab_button_primary(page)}>Submit</button>
                        </div>
                    </div>
                    <textarea id="output" class={display_editor(page)} placeholder="Press the submit button"></textarea>
                </div>
            </div>

            {Footer(page)}
        </div>
    }
}