import HTML
import MarkdownABI
import MarkdownRendering
import Testing_

@main
enum Main:TestMain, TestBattery
{
    private static
    func run(tests:TestGroup,
        expecting expected:String,
        plain:String,
        from markdown:(inout Markdown.BinaryEncoder) -> ())
    {
        tests.do
        {
            let binary:MarkdownBinary = .init(bytecode: .init(with: markdown))

            if  let tests:TestGroup = tests / "HTML"
            {
                let html:HTML = .init { $0 += binary }
                tests.expect("\(html)" ==? expected)
            }

            if  let tests:TestGroup = tests / "PlainText"
            {
                tests.expect("\(binary)" ==? plain)
            }
        }
    }

    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Links" / "External"
        {
            self.run(tests: tests,
                expecting: """
                <a class='xv' href='https://swiftinit.org/x' \
                target='_blank' rel='external nofollow noopener ugc'>x</a>
                """,
                plain: "x")
            {
                $0[.identifier] { $0[.external] = "https://swiftinit.org/x" } = "x"
            }
        }
        if  let tests:TestGroup = tests / "Links" / "Safe"
        {
            self.run(tests: tests,
                expecting: """
                <a class='xv' href='https://swiftinit.org/x' \
                target='_blank' rel='external'>x</a>
                """,
                plain: "x")
            {
                $0[.identifier] { $0[.safelink] = "https://swiftinit.org/x" } = "x"
            }
        }
        if  let tests:TestGroup = tests / "Pre" / "Transparency"
        {
            //  The markdown VM cannot parse inline HTML, so this will generate no plain text.
            self.run(tests: tests,
                expecting: "<pre><span>test</span></pre>",
                plain: "")
            {
                $0[.pre]
                {
                    $0[.transparent] = "<span>test</span>"
                }
            }
        }
        if  let tests:TestGroup = tests / "Pre" / "EscapedCharacters"
        {
            self.run(tests: tests,
                expecting: "<pre>&lt;span&gt;test&lt;/span&gt;</pre>",
                plain: "<span>test</span>")
            {
                $0[.pre] = "<span>test</span>"
            }
        }
        if  let tests:TestGroup = tests / "Pre" / "Newlines"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Pre" / "Language"
        {
            self.run(tests: tests,
                expecting: "<pre class='language-swift'>code\ncode</pre>",
                plain: "code\ncode")
            {
                $0[.pre, { $0[.language] = "swift" }] = "code\ncode"
            }
        }
        if  let tests:TestGroup = tests / "Pre" / "Language" / "ExtraCSS" / "Before"
        {
            self.run(tests: tests,
                expecting: "<pre class='before language-swift'>code\ncode</pre>",
                plain: "code\ncode")
            {
                $0[.pre, { $0[.class] = "before" ; $0[.language] = "swift" }] = "code\ncode"
            }
        }
        if  let tests:TestGroup = tests / "Pre" / "Language" / "ExtraCSS" / "After"
        {
            self.run(tests: tests,
                expecting: "<pre class='language-swift after'>code\ncode</pre>",
                plain: "code\ncode")
            {
                $0[.pre, { $0[.language] = "swift" ; $0[.class] = "after" }] = "code\ncode"
            }
        }
        if  let tests:TestGroup = tests / "Pre" / "Language" / "EscapedCharacters"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Pre" / "Highlighting"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Pre" / "Unicode"
        {
            self.run(tests: tests,
                expecting: """
                <pre class='language-swift'>let 🇺🇸 = "en-us"</pre>
                """,
                plain: "let 🇺🇸 = \"en-us\"")
            {
                $0[.pre, { $0[.language] = "swift" }] = "let 🇺🇸 = \"en-us\""
            }
        }
        if  let tests:TestGroup = tests / "Snippet" / "SingleLine"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Snippet" / "MultiLine"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Snippet" / "Trimming"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "MultipleClasses"
        {
            self.run(tests: tests,
                expecting: "<p class='aaa bbb ccc'> </p>",
                plain: " ")
            {
                $0[.p, { $0[.class] = "aaa"; $0[.class] = "bbb"; $0[.class] = "ccc" }] = " "
            }
        }
        if  let tests:TestGroup = tests / "VoidElements"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Attributes" / "Nesting"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Attributes" / "Checkbox"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Attributes" / "Align"
        {
            for pseudo:Markdown.Bytecode.Attribute in [.center, .left, .right]
            {
                if  let tests:TestGroup = tests / "\(pseudo)"
                {
                    self.run(tests: tests,
                        expecting: "<td align='\(pseudo)'> </td>",
                        plain: " ")
                    {
                        $0[.td, { $0[pseudo] = true }] = " "
                    }
                }
            }
        }
        if  let tests:TestGroup = tests / "Sections"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "Signage"
        {
            self.run(tests: tests,
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
        if  let tests:TestGroup = tests / "References"
        {
            self.run(tests: tests,
                expecting: """
                <p><code>&lt;reference = 12345&gt;</code></p>
                """,
                plain: "<reference = 12345>")
            {
                $0[.p] { $0 &= 12345 }
            }

            for (name, reference):(String, Int) in
            [
                ("min",     .min),
                ("uint8",    255),
                ("uint16", 65535),
                ("max",     .max),
            ]
            {
                guard let tests:TestGroup = tests / name
                else
                {
                    continue
                }
                self.run(tests: tests,
                    expecting: """
                    <p><code>&lt;reference = \(reference)&gt;</code></p>
                    """,
                    plain: "<reference = \(reference)>")
                {
                    $0[.p] { $0 &= reference }
                }
            }
        }
        if  let tests:TestGroup = tests / "References" / "Success"
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

            tests.expect(html.description ==?
                "<p>before<a href='https://swiftinit.org'>aabbccdd</a>after</p>")
        }
        if  let tests:TestGroup = tests / "ReferenceAttributes"
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

            for (name, reference):(String, Int) in
            [
                ("-1",        -1),
                ("uint8",    255),
                ("uint16", 65535),
                ("max",     .max),
            ]
            {
                guard let tests:TestGroup = tests / name
                else
                {
                    continue
                }

                let renderable:Renderable = .init(reference: reference)
                let html:HTML = .init { $0 += renderable }

                tests.expect(html.description ==? """
                    <pre><code>\
                    <span class='xk'>let</span> \
                    <span class='xv'>x</span>:\
                    <a class='xt' href='https://swiftinit.org'>Int</a>\
                    </code></pre>
                    """)
            }

            if  let tests:TestGroup = tests / "Failure"
            {
                let renderable:Renderable = .init(reference: 2)
                let html:HTML = .init { $0 += renderable }

                tests.expect(html.description ==? """
                    <pre><code>\
                    <span class='xk'>let</span> \
                    <span class='xv'>x</span>:\
                    <span class='xt'>Int</span>\
                    </code></pre>
                    """)
            }
        }
    }
}
