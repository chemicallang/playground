
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
// please note that this stuff is very experimental
// expected to mostly work, if fails, file an issue

func give_me_fruit() : *char {
    return "Bell pepper"
}

func style_banana(page : &mut HtmlPage) : *char {
    // some properties aren't supported like 'background'
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
    // dynamic values change the class name (begin with .r)
    // because this can't be hashed (because runtime value, unknown)
    // dynamic values in css can exist in place of color, length, etc... (not everywhere)
    // warning: multiple invocations of this function cause multiple styles
    //          this will be fixed in the future (using custom user given hash)
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

    printf("complete page:\\n");
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