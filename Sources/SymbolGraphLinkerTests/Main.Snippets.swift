import MarkdownPluginSwift
import Testing

extension Main
{
    struct Snippets
    {
    }
}
extension Main.Snippets:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "MissingFinalNewline"
        {
            Self.run(tests: tests,
                snippet:
                """
                print("Hi Barbie!")
                """,
                caption:
                """
                """,
                slices:
                """
                print("Hi Barbie!")
                """)
        }
        if  let tests:TestGroup = tests / "NoCaption"
        {
            Self.run(tests: tests,
                snippet:
                """
                print("Hi Barbie!")

                """,
                caption:
                """
                """,
                slices:
                """
                print("Hi Barbie!")

                """)
        }
        if  let tests:TestGroup = tests / "WithCaption"
        {
            Self.run(tests: tests,
                snippet:
                """
                //  Here’s how to say ‘hi’ to Barbie.

                print("Hi Barbie!")

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """
                print("Hi Barbie!")

                """)
        }
        if  let tests:TestGroup = tests / "WithCaptionDocComment"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.
                ///
                /// This is a multi-line comment.

                print("Hi Barbie!")

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.

                This is a multi-line comment.
                """,
                slices:
                """
                print("Hi Barbie!")

                """)
        }
        if  let tests:TestGroup = tests / "CollapseWhitespace"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.



                print("Hi Barbie!")

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """
                print("Hi Barbie!")

                """)
        }
        if  let tests:TestGroup = tests / "TriviaOnly"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.

                // print("Hi Barbie!")

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """
                // print("Hi Barbie!")

                """)
        }
        if  let tests:TestGroup = tests / "TriviaOnlyManualViewbox"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.

                // snippet.HI_BARBIE

                // print("Hi Barbie!")



                // snippet.end

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """

                // print("Hi Barbie!")

                """)
        }
        if  let tests:TestGroup = tests / "Indented"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.

                @main
                enum Main
                {
                    // snippet.HI_BARBIE
                    static func main()
                    {
                        print("Hi Barbie!")
                    }
                    // snippet.end
                }

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """
                @main
                enum Main
                {

                """,
                """
                static func main()
                {
                    print("Hi Barbie!")
                }

                """)
        }
        if  let tests:TestGroup = tests / "IndentedNonContiguous"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.
                //  snippet.end
                @main
                enum Main
                {
                    // snippet.HI_BARBIE
                    static func main()
                    {
                        print("Hi Barbie!")

                        //  snippet.hide

                        print("Hi Ken!")

                        //  snippet.show
                    }
                    // snippet.end
                }

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """
                """,
                """
                static func main()
                {
                    print("Hi Barbie!")
                }

                """)
        }
        if  let tests:TestGroup = tests / "Empty"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.

                // snippet.end
                @main
                enum Main
                {
                    // snippet.HI_BARBIE

                    // snippet.end
                    static func main()
                    {
                        print("Hi Barbie!")
                    }
                }

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie.
                """,
                slices:
                """
                """,
                """
                """)
        }
    }
}
extension Main.Snippets
{
    private static
    func run(tests:TestGroup, snippet:String, caption:String, slices expected:String...)
    {
        let swift:Markdown.SwiftLanguage = .swift
        let (caption, slices):(String, [Markdown.SnippetSlice]) = swift.parse(
            snippet: [_].init(snippet.utf8))

        if  let tests:TestGroup = tests / "Caption"
        {
            tests.expect(caption ==? caption)
        }
        if  let tests:TestGroup = tests / "Count"
        {
            tests.expect(slices.count ==? expected.count)
        }
        for (i, expected):(Int, String) in expected.enumerated()
        {
            guard
            let tests:TestGroup = tests / "\(i)"
            else
            {
                continue
            }
            if  slices.indices.contains(i)
            {
                tests.expect("\(slices[i].code.safe)" ==? expected)
            }
            else
            {
                tests.expect(value: nil as Markdown.SnippetSlice?)
                continue
            }
        }
    }
}
