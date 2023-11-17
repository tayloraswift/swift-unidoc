import Testing

extension Main
{
    struct Topics
    {
    }
}
extension Main.Topics:MarkdownTestBattery
{
    static
    func run(tests:TestGroup)
    {
        let html:String =
        """
        <p>Overview overview overview</p>
        <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
        <p>Details details details</p>
        """
        if  let tests:TestGroup = tests / "OneList" / "ImplicitTopic"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Topics

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ## Discussion

                Details details details
                """,
                expected: html,
                topics: [3])
        }
        if  let tests:TestGroup = tests / "OneList" / "OneTopic" / "Middle"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Topics

                ### Chase Icon

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ## Discussion

                Details details details
                """,
                expected: html,
                topics: [3])
        }
        if  let tests:TestGroup = tests / "OneList" / "OneTopic" / "End"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Discussion

                Details details details

                ## Topics

                ### Chase Icon

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>
                """,
                expected: html,
                topics: [3])
        }
        if  let tests:TestGroup = tests / "OneList" / "ManyTopics"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Discussion

                Details details details

                ## Topics

                ### Chase Icon

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ### Taylor Swift

                -   ``WeAreNeverEverGettingBackTogether``
                -   ``AllTooWell``

                """,
                expected: html,
                topics: [3, 2])
        }
        if  let tests:TestGroup = tests / "ManyLists"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Topics

                ### Dua Lipa

                -   ``DanceTheNight``

                ## Discussion

                Details details details

                ## Topics

                ### Chase Icon

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ### Taylor Swift

                -   ``WeAreNeverEverGettingBackTogether``
                -   ``AllTooWell``

                """,
                expected: html,
                topics: [1, 3, 2])
        }
        if  let tests:TestGroup = tests / "ManyLists" / "Discussions"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Topics

                ### Dua Lipa

                Selected songs by Dua Lipa.

                -   ``DanceTheNight``

                ## Discussion

                Details details details

                ## Topics

                ### Chase Icon

                Lyrics from *Like Me*.

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ### Taylor Swift

                Selected songs by Taylor Swift.

                >   Note: These are from the original Red album.

                -   ``WeAreNeverEverGettingBackTogether``
                -   ``AllTooWell``

                """,
                expected: html,
                topics: [1, 3, 2])
        }
    }
}
