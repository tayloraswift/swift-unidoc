import MarkdownPluginSwift
import Testing

@Suite
struct Snippets
{
    @Test
    static func MissingFinalNewline()
    {
        Self.test(
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
    @Test
    static func NoCaption()
    {
        Self.test(
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
    @Test
    static func NoCaptionButHidden()
    {
        Self.test(
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
    @Test
    static func NoCaptionButSliced()
    {
        Self.test(
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
    @Test
    static func NoCaptionButSlicedAndTrimmed()
    {
        Self.test(
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
    @Test
    static func WithCaption()
    {
        Self.test(
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
    @Test
    static func WithCaptionDocComment()
    {
        Self.test(
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
    @Test
    static func TriviaOnly()
    {
        Self.test(
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
    @Test
    static func TriviaOnlyManualViewbox()
    {
        Self.test(
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
    @Test
    static func Indented()
    {
        Self.test(
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
    @Test
    static func IndentedNonContiguous()
    {
        Self.test(
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
    @Test
    static func AnonymousNonContiguous()
    {
        Self.test(
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
    @Test
    static func AnonymousExplicitShow()
    {
        Self.test(
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
    @Test
    static func AnonymousCollapseWhitespace()
    {
        Self.test(
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
    @Test
    static func NominalCollapseWhitespace()
    {
        Self.test(
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
    @Test
    static func Empty()
    {
        Self.test(
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
extension Snippets
{
    private
    static func test(snippet:String,
        caption captionExpectation:String,
        slices sliceExpectations:String...)
    {
        let swift:Markdown.SwiftLanguage = .swift
        let (caption, slices):(String, [Markdown.SnippetSlice]) = swift.parse(
            snippet: [_].init(snippet.utf8))

        #expect(caption == captionExpectation)
        #expect(slices.count == sliceExpectations.count)

        for (i, sliceExpectation):(Int, String) in sliceExpectations.enumerated()
        {
            if  slices.indices.contains(i)
            {
                #expect("\(slices[i].text)" == sliceExpectation)
            }
        }
    }
}
