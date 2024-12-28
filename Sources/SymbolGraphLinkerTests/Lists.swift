import Testing

@Suite
struct Lists:MarkdownTestSuite
{
    @Test
    static func Asides() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Attention: i am very pretty.
            - Complexity: i am very complex.

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='attention'>\
            <h3>Attention</h3>\
            <p>i am very pretty.</p>\
            </aside>\
            <aside class='complexity'>\
            <h3>Complexity</h3>\
            <p>i am very complex.</p>\
            </aside>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Formatting() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - **Attention**: i am very pretty.
            - *Complexity*: i am very complex.

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <aside class='attention'>\
            <h3>Attention</h3>\
            <p>i am very pretty.</p>\
            </aside>\
            <aside class='complexity'>\
            <h3>Complexity</h3>\
            <p>i am very complex.</p>\
            </aside>\
            <p>Details details details</p>
            """)
    }
}
