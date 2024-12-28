import MarkdownABI
import MarkdownPluginSwift
import Symbols
import Testing

@Suite
struct Blockquotes:MarkdownTestSuite
{
    @Test
    static func Literal() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > equality implies substitutability and u r irreplaceable 💝
                — barbie

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <blockquote>\
            <p>equality implies substitutability and u r irreplaceable 💝 — barbie</p>\
            </blockquote>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func LiteralColon() throws
    {
        //  Apostrophe will become a curly quote, due to cmark-gfm smart punctuation.
        try Self.test(
            markdown: """
            Overview overview overview
            > Miranda: Don't be ridiculous, Andrea. Everybody wants this.

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <blockquote>\
            <p>Miranda: Don’t be ridiculous, Andrea. Everybody wants this.</p>\
            </blockquote>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Asides() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > Important:
                A barbie princess is not the same thing as a
                princess barbie.

            Details details details
            > Tip:
                Barbie princesses love sloths! Unless they are
                liberal. Barbie princesses hate liberals.

            Even more details
            > Note:
                Princess barbies never care about sloth politics.
                To ignore liberal sloths, convert barbie princesses
                into princess barbies.
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='important'>\
            <h3>Important</h3>\
            <p>A barbie princess is not the same thing as a princess barbie.</p>\
            </aside>\
            <p>Details details details</p>\
            <aside class='tip'>\
            <h3>Tip</h3>\
            <p>Barbie princesses love sloths! Unless they are liberal. Barbie \
            princesses hate liberals.</p>\
            </aside>\
            <p>Even more details</p>\
            <aside class='note'>\
            <h3>Note</h3>\
            <p>Princess barbies never care about sloth politics. To ignore \
            liberal sloths, convert barbie princesses into princess barbies.</p>\
            </aside>
            """)
    }
    @Test
    static func AsidesFromSnippetCaptions() throws
    {
        let markdownParser:Markdown.Parser<Markdown.SwiftComment> = .init()
        let swiftParser:Markdown.SwiftLanguage = .swift
        let swiftSource:String = """
        //  > Tip:
        //  Liberal barbies never care about political sloths. To ignore political sloths,
        //  convert sloth politics into liberal barbies.

        let barbie:Barbie = .convert(sloth, type: .liberal)

        """

        let snippet:(caption:String, slices:[Markdown.SnippetSlice]) = swiftParser.parse(
            snippet: [UInt8].init(swiftSource.utf8))

        let snippets:[String: Markdown.Snippet] =
        [
            "Example": .init(id: 0,
                captionParser: markdownParser,
                caption: snippet.caption,
                slices: snippet.slices)
        ]

        try Self.test(
            snippets: snippets,
            markdown: """
            Overview overview overview

            @Snippet(id: Example)
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='tip'>\
            <h3>Tip</h3>\
            <p>Liberal barbies never care about political sloths. To ignore political \
            sloths, convert sloth politics into liberal barbies.</p>\
            </aside>\
            <pre class='snippet'><code class='language-swift'>\
            <span class='newline'></span>\
            <span class='xk'>let</span> <span class='xv'>barbie</span>:\
            <span class='xt'>Barbie</span> = .\
            <span class='xv'>convert</span>(<span class='xv'>sloth</span>, \
            <span class='xv'>type</span>: .<span class='xv'>liberal</span>)\
            </code></pre>
            """)
    }
    @Test
    static func Formatting() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > **Important**:
                A barbie princess is not the same thing as a
                princess barbie.

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='important'>\
            <h3>Important</h3>\
            <p>A barbie princess is not the same thing as a princess barbie.</p>\
            </aside>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Capitalization() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > IMPORTANT: i am an important businessman.
                A VERY IMPORTANT BUSINESSMAN

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='important'>\
            <h3>Important</h3>\
            <p>i am an important businessman. A VERY IMPORTANT BUSINESSMAN</p>\
            </aside>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Wordbreaks() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > nonmutating variant: Humans on top!

            > non mutatingvariant: Humans on top!

            > nonmutatingvariant: Humans on top!

            > non-mutating-variant: Humans on top!

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='nonmutatingvariant'>\
            <h3>Non-mutating Variant</h3>\
            <p>Humans on top!</p>\
            </aside>\
            <aside class='nonmutatingvariant'>\
            <h3>Non-mutating Variant</h3>\
            <p>Humans on top!</p>\
            </aside>\
            <aside class='nonmutatingvariant'>\
            <h3>Non-mutating Variant</h3>\
            <p>Humans on top!</p>\
            </aside>\
            <aside class='nonmutatingvariant'>\
            <h3>Non-mutating Variant</h3>\
            <p>Humans on top!</p>\
            </aside>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Standalone() throws
    {
        try Self.test(
            markdown: """
            >   Important:
                A barbie princess is not the same thing as a
                princess barbie.

            Details details details
            """,
            expected: """

            <aside class='important'>\
            <h3>Important</h3>\
            <p>A barbie princess is not the same thing as a princess barbie.</p>\
            </aside>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Parameters() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > Parameters:
                Discussion about parameters in general.

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <p>Discussion about parameters in general.</p>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func ParameterOne() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > Parameter parameter:
                Description for `parameter`

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:parameter'><a href='#sp:parameter'>parameter</a></dt>\
            <dd><p>Description for <code>parameter</code></p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func ParameterMany() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > Parameter first:
                Description for `first`

            Details details details

            > Parameter second:
                Description for `second`

            Even more details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for <code>first</code></p></dd>\
            <dt id='sp:second'><a href='#sp:second'>second</a></dt>\
            <dd><p>Description for <code>second</code></p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>\
            <p>Even more details</p>
            """)
    }
    @Test
    static func ParameterFormatting() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            > **Parameter** `parameter`:
                Description for `parameter`

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:parameter'><a href='#sp:parameter'>parameter</a></dt>\
            <dd><p>Description for <code>parameter</code></p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
}
