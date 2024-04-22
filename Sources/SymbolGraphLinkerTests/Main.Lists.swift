import Testing_

extension Main
{
    struct Lists
    {
    }
}
extension Main.Lists:MarkdownTestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Asides"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview
                - Attention: i am very pretty.
                - Complexity: i am very complex.

                Details details details
                """,
                expected:
                """
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
        if  let tests:TestGroup = tests / "Formatting"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview
                - **Attention**: i am very pretty.
                - *Complexity*: i am very complex.

                Details details details
                """,
                expected:
                """
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
}
