import MarkdownPluginSwift
import Testing_

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
        if  let tests:TestGroup = tests / "NoCaptionButHidden"
        {
            Self.run(tests: tests,
                snippet:
                """
                //  snippet.hide
                import Barbie

                //  snippet.show
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
        if  let tests:TestGroup = tests / "NoCaptionButSliced"
        {
            Self.run(tests: tests,
                snippet:
                """
                //  snippet.HI_BARBIE
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
        if  let tests:TestGroup = tests / "NoCaptionButSlicedAndTrimmed"
        {
            Self.run(tests: tests,
                snippet:
                """
                //  snippet.HI_BARBIE

                print("Hi Barbie!")

                //  snippet.end

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
                /// Here’s how to say ‘hi’ to Barbie and Skipper.

                // snippet.HI_BARBIE

                // print("Hi Barbie!")

                // snippet.hide

                // snippet.show

                // print("Hi Skipper!")

                // snippet.end

                """,
                caption:
                """
                Here’s how to say ‘hi’ to Barbie and Skipper.

                """,
                slices: // This should preserve the empty line before `Hi Skipper!`.
                """
                // print("Hi Barbie!")

                // print("Hi Skipper!")
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
                static func main()
                {
                    print("Hi Barbie!")
                }
                """)
        }
        if  let tests:TestGroup = tests / "AnonymousNonContiguous"
        {
            Self.run(tests: tests,
                snippet:
                """
                //  Here’s how to say ‘hi’ to Barbie.

                //  snippet.hide
                @main
                enum Main
                {
                    // snippet.show
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
                static func main()
                {
                    print("Hi Barbie!")
                }
                """)
        }
        if  let tests:TestGroup = tests / "AnonymousExplicitShow"
        {
            Self.run(tests: tests,
                snippet:
                """
                //  Here’s how to say ‘hi’ to Barbie.
                @main
                enum Main
                {
                    // snippet.show
                    static func main()
                    {
                        print("Hi Barbie!")

                        print("Hi Ken!")
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
                static func main()
                {
                    print("Hi Barbie!")

                    print("Hi Ken!")
                }
                """)
        }
        if  let tests:TestGroup = tests / "AnonymousCollapseWhitespace"
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
        if  let tests:TestGroup = tests / "NominalCollapseWhitespace"
        {
            Self.run(tests: tests,
                snippet:
                """
                /// Here’s how to say ‘hi’ to Barbie.


                //  snippet.BARBIE

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
                """)
        }
    }
}
extension Main.Snippets
{
    private static
    func run(tests:TestGroup,
        snippet:String,
        caption captionExpectation:String,
        slices sliceExpectations:String...)
    {
        let swift:Markdown.SwiftLanguage = .swift
        let (caption, slices):(String, [Markdown.SnippetSlice]) = swift.parse(
            snippet: [_].init(snippet.utf8))

        if  let tests:TestGroup = tests / "Caption"
        {
            tests.expect(caption ==? captionExpectation)
        }
        if  let tests:TestGroup = tests / "Count"
        {
            tests.expect(slices.count ==? sliceExpectations.count)
        }
        for (i, sliceExpectation):(Int, String) in sliceExpectations.enumerated()
        {
            guard
            let tests:TestGroup = tests / "\(i)"
            else
            {
                continue
            }
            if  slices.indices.contains(i)
            {
                tests.expect("\(slices[i].text)" ==? sliceExpectation)
            }
        }
    }
}
