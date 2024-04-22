import Testing_

extension Main
{
    struct ListsWithMultipleItems
    {
    }
}
extension Main.ListsWithMultipleItems:MarkdownTestBattery
{
    static
    func run(tests:TestGroup)
    {
        let html:String =
        """
        <p>Overview overview overview</p>\

        <section class='parameters'>\
        <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
        <p>Discussion about parameters in general.</p>\
        <dl>\
        <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
        <dd><p>Description for first parameter</p></dd>\
        </dl>\
        </section>\
        <section class='returns'>\
        <h2 id='ss:returns'><a href='#ss:returns'>Returns</a></h2>\
        <p>Discussion about return value.</p>\
        </section>\
        <aside class='warning'>\
        <h3>Warning</h3>\
        <p>This function is known by the state of california to cause cancer!</p>\
        </aside>\
        <p>Details details details</p>
        """
        if  let tests:TestGroup = tests / "Basic"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview
                - Parameters:
                    Discussion about parameters in general.
                    - first: Description for first parameter
                - Returns:
                    Discussion about return value.
                - Warning:
                    This function is known by the state of
                    california to cause cancer!

                Details details details
                """,
                expected: html)
        }
        if  let tests:TestGroup = tests / "Interlopers"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview
                - Parameters:
                    Discussion about parameters in general.
                    - first: Description for first parameter
                - Warning:
                    This function is known by the state of
                    california to cause cancer!
                - Returns:
                    Discussion about return value.

                Details details details
                """,
                expected: html)
        }
        if  let tests:TestGroup = tests / "Reordering"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview
                - Returns:
                    Discussion about return value.
                - Warning:
                    This function is known by the state of
                    california to cause cancer!
                - Parameters:
                    Discussion about parameters in general.
                    - first: Description for first parameter

                Details details details
                """,
                expected: html)
        }
    }
}
