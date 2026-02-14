
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
    print_vec(vec)
    vec.clear()
    printf("Your vector contains : ")
    print_vec(vec)

    // creating map
    var map = std::unordered_map<std::string_view, std::string_view>()
    map.insert(std::string_view("person1"), std::string_view("Patrick"))
    map.insert(std::string_view("person2"), std::string_view("Ulrich"))
    map.insert(std::string_view("person3"), std::string_view("Sarah"))
    map.insert(std::string_view("person4"), std::string_view("Scott"))
    map.insert(std::string_view("person5"), std::string_view("Yuri"))
    print_map(map)
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

func print_vec(vec : &mut std::vector<int>) {
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

func print_map(map : &mut std::unordered_map<std::string_view, std::string_view>) {
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
module main
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
    str.append_expr(\`Today is {day} and there are {count} days in a week\`)
    printf("%s\\n", str.data());

    // send to command line
    var pi = 3.14f
    var msg = "I remember it"
    println(\`The value of pi is {pi} and {msg}\`)


    print(\`{"\\n\\n"}Long Live Chemical{"\\n\\n"}\`)
    return 0;
}
"""
        mod : """
module main
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
module main
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
module main
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