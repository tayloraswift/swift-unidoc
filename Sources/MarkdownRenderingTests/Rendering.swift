import HTML
import MarkdownABI
import MarkdownRendering
import Testing

@Suite
struct Rendering
{
    @Test
    static func LinksExternal()
    {
        Self.test(
            expecting: """
            <a class='xv' href='https://swiftinit.org/x' \
            target='_blank' rel='external nofollow noopener ugc'>x</a>
            """,
            plain: "x")
        {
            $0[.identifier] { $0[.external] = "https://swiftinit.org/x" } = "x"
        }
    }
    @Test
    static func LinksSafe()
    {
        Self.test(
            expecting: """
            <a class='xv' href='https://swiftinit.org/x' \
            target='_blank' rel='external'>x</a>
            """,
            plain: "x")
        {
            $0[.identifier] { $0[.safelink] = "https://swiftinit.org/x" } = "x"
        }
    }
    @Test
    static func PreTransparency()
    {
        //  The markdown VM cannot parse inline HTML, so this will generate no plain text.
        Self.test(
            expecting: "<pre><span>test</span></pre>",
            plain: "")
        {
            $0[.pre]
            {
                $0[.transparent] = "<span>test</span>"
            }
        }
    }
    @Test
    static func PreEscapedCharacters()
    {
        Self.test(
            expecting: "<pre>&lt;span&gt;test&lt;/span&gt;</pre>",
            plain: "<span>test</span>")
        {
            $0[.pre] = "<span>test</span>"
        }
    }
    @Test
    static func PreNewlines()
    {
        Self.test(
            expecting: "<pre>    code\n    code</pre>",
            plain: "    code\n    code")
        {
            $0[.pre] =
            """
                code
                code
            """
        }
    }
    @Test
    static func PreLanguage()
    {
        Self.test(
            expecting: "<pre class='language-swift'>code\ncode</pre>",
            plain: "code\ncode")
        {
            $0[.pre, { $0[.language] = "swift" }] = "code\ncode"
        }
    }
    @Test
    static func PreLanguageExtraCSSBefore()
    {
        Self.test(
            expecting: "<pre class='before language-swift'>code\ncode</pre>",
            plain: "code\ncode")
        {
            $0[.pre, { $0[.class] = "before" ; $0[.language] = "swift" }] = "code\ncode"
        }
    }
    @Test
    static func PreLanguageExtraCSSAfter()
    {
        Self.test(
            expecting: "<pre class='language-swift after'>code\ncode</pre>",
            plain: "code\ncode")
        {
            $0[.pre, { $0[.language] = "swift" ; $0[.class] = "after" }] = "code\ncode"
        }
    }
    @Test
    static func PreLanguageEscapedCharacters()
    {
        Self.test(
            expecting: """
            <pre class='language-taylor&#39;s version'>\
            we r never ever ever getting back together\
            </pre>
            """,
            plain: "we r never ever ever getting back together")
        {
            $0[.pre, { $0[.language] = "taylor's version" }] =
                "we r never ever ever getting back together"
        }
    }
    @Test
    static func PreHighlighting()
    {
        Self.test(
            expecting: """
            <pre class='language-swift'>\
            <span class='xk'>let</span> \
            <span class='xv'>x</span> = \
            <span class='xn'>5</span>\
            </pre>
            """,
            plain: "let x = 5")
        {
            $0[.pre, { $0[.language] = "swift" }]
            {
                $0[.keyword] = "let"
                $0 += " "
                $0[.identifier] = "x"
                $0 += " = "
                $0[.literalNumber] = "5"
            }
        }
    }
    @Test
    static func PreUnicode()
    {
        Self.test(
            expecting: """
            <pre class='language-swift'>let 🇺🇸 = "en-us"</pre>
            """,
            plain: "let 🇺🇸 = \"en-us\"")
        {
            $0[.pre, { $0[.language] = "swift" }] = "let 🇺🇸 = \"en-us\""
        }
    }
    @Test
    static func SnippetSingleLine()
    {
        Self.test(
            expecting: """
            <pre class='snippet'>\
            <code class='language-swift'>\
            <span class='newline'></span><span class='xk'>let</span> \
            <span class='xv'>x</span> = \
            <span class='xn'>5</span>\
            </code>\
            </pre>
            """,
            plain: "let x = 5")
        {
            $0[.snippet, { $0[.language] = "swift" }]
            {
                $0[.keyword] = "let"
                $0 += " "
                $0[.identifier] = "x"
                $0 += " = "
                $0[.literalNumber] = "5"
            }
        }
    }
    @Test
    static func SnippetMultiLine()
    {
        Self.test(
            expecting: """
            <pre class='snippet'>\
            <code class='language-swift'>\
            <span class='newline'></span><span class='xk'>import</span> \
            NIOCore\
            <span class='newline'>


            </span><span class='xk'>let</span> \
            <span class='xv'>x</span> = \
            <span class='xn'>5</span>\
            </code>\
            </pre>
            """,
            plain: """
            import NIOCore


            let x = 5
            """)
        {
            $0[.snippet, { $0[.language] = "swift" }]
            {
                $0[.keyword] = "import"
                $0 += """
                 \
                NIOCore



                """
                $0[.keyword] = "let"
                $0 += " "
                $0[.identifier] = "x"
                $0 += " = "
                $0[.literalNumber] = "5"
            }
        }
    }
    @Test
    static func SnippetTrimming()
    {
        Self.test(
            expecting: """
            <pre class='snippet'>\
            <code class='language-swift'>\
            <span class='newline'></span>\
            <span class='newline'>

            </span>import NIOCore\
            </code>\
            </pre>
            """,
            plain: """


            import NIOCore


            """)
        {
            $0[.snippet, { $0[.language] = "swift" }] =
            """


            import NIOCore


            """
        }
    }
    @Test
    static func MultipleClasses()
    {
        Self.test(
            expecting: "<p class='aaa bbb ccc'> </p>",
            plain: " ")
        {
            $0[.p, { $0[.class] = "aaa"; $0[.class] = "bbb"; $0[.class] = "ccc" }] = " "
        }
    }
    @Test
    static func VoidElements()
    {
        Self.test(
            expecting: "<p><br><br><br></p>",
            plain: "")
        {
            $0[.p]
            {
                $0[.br]
                $0[.br]
                $0[.br]
            }
        }
    }
    @Test
    static func AttributesNesting()
    {
        Self.test(
            expecting: """
            <h1 class='a'>\
            <em class='b'>go to</em>\
            <a class='c' href='swift.org'>\
            <em class='d'>swift website</em>\
            </a>\
            <em class='e'>.</em>\
            </h1>
            """,
            plain: "go toswift website.")
        {
            $0[.h1, { $0[.class] = "a" }]
            {
                $0[.em, { $0[.class] = "b" }] = "go to"
                $0[.a, { $0[.class] = "c" ; $0[.href] = "swift.org" }]
                {
                    $0[.em, { $0[.class] = "d" }] = "swift website"
                }
                $0[.em, { $0[.class] = "e" }] = "."
            }
        }
    }
    @Test
    static func AttributesCheckbox()
    {
        Self.test(
            expecting: "<input type='checkbox' checked disabled>",
            plain: "")
        {
            $0[.input]
            {
                $0[.checkbox] = true
                $0[.checked] = true
                $0[.disabled] = true
            }
        }
    }
    @Test
    static func AttributesAlign()
    {
        for pseudo:Markdown.Bytecode.Attribute in [.center, .left, .right]
        {
            Self.test(
                expecting: "<td align='\(pseudo)'> </td>",
                plain: " ")
            {
                $0[.td, { $0[pseudo] = true }] = " "
            }
        }
    }
    @Test
    static func Sections()
    {
        Self.test(
            expecting: """
            <section class='custom parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt>name</dt><dd>documentation</dd>\
            </dl>\
            </section>
            """,
            plain: "namedocumentation")
        {
            $0[.parameters, { $0[.class] = "custom" }]
            {
                $0[.dl]
                {
                    $0[.dt] = "name"
                    $0[.dd] = "documentation"
                }
            }
        }
    }
    @Test
    static func Signage()
    {
        Self.test(
            expecting: """
            <aside class='warning'>\
            <h3>Warning</h3>\
            <p>don’t use this!</p>\
            </aside>
            """,
            plain: "don’t use this!")
        {
            $0[.warning]
            {
                $0[.p] = "don’t use this!"
            }
        }
    }
    @Test
    static func References()
    {
        Self.test(
            expecting: """
            <p><code>&lt;reference = 12345&gt;</code></p>
            """,
            plain: "<reference = 12345>")
        {
            $0[.p] { $0 &= 12345 }
        }

        for reference:Int in [.min, 255, 65535, .max]
        {
            Self.test(
                expecting: """
                <p><code>&lt;reference = \(reference)&gt;</code></p>
                """,
                plain: "<reference = \(reference)>")
            {
                $0[.p] { $0 &= reference }
            }
        }
    }
    @Test
    static func ReferencesSuccess()
    {
        struct Renderable:HTML.OutputStreamableMarkdown
        {
            let bytecode:Markdown.Bytecode = .init
            {
                $0[.p]
                {
                    $0 += "before"
                    $0 &= 0xAA_BB_CC_DD
                    $0 += "after"
                }
            }

            func load(_ reference:Int, into html:inout HTML.ContentEncoder)
            {
                html[.a, { $0.href = "https://swiftinit.org" }] = String.init(reference,
                    radix: 16)
            }
        }

        let renderable:Renderable = .init()
        let html:HTML = .init { $0 += renderable }

        #expect(html.description ==
            "<p>before<a href='https://swiftinit.org'>aabbccdd</a>after</p>")
    }
    @Test
    static func ReferenceAttributes()
    {
        struct Renderable:HTML.OutputStreamableMarkdown
        {
            let bytecode:Markdown.Bytecode

            init(reference:Int)
            {
                self.bytecode = .init
                {
                    $0[.pre]
                    {
                        $0[.code]
                        {
                            $0[.keyword] = "let"
                            $0 += " "
                            $0[.identifier] = "x"
                            $0 += ":"
                            $0[.type, { $0[.href] = reference }] = "Int"
                        }
                    }
                }
            }

            func load(_ reference:Int, for _:inout Markdown.Bytecode.Attribute) -> String?
            {
                reference & 1 == 0 ? nil : "https://swiftinit.org"
            }
        }

        for reference:Int in [-1, 255, 65535, .max]
        {
            let renderable:Renderable = .init(reference: reference)
            let html:HTML = .init { $0 += renderable }

            #expect(html.description == """
                <pre><code>\
                <span class='xk'>let</span> \
                <span class='xv'>x</span>:\
                <a class='xt' href='https://swiftinit.org'>Int</a>\
                </code></pre>
                """)
        }

        do
        {
            let renderable:Renderable = .init(reference: 2)
            let html:HTML = .init { $0 += renderable }

            #expect(html.description == """
                <pre><code>\
                <span class='xk'>let</span> \
                <span class='xv'>x</span>:\
                <span class='xt'>Int</span>\
                </code></pre>
                """)
        }
    }
}
extension Rendering
{
    private
    static func test(
        expecting expected:String,
        plain:String,
        from markdown:(inout Markdown.BinaryEncoder) -> ())
    {
        let binary:MarkdownBinary = .init(bytecode: .init(with: markdown))
        let html:HTML = .init { $0 += binary }
        #expect("\(html)" == expected)
        #expect("\(binary)" == plain)
    }
}
