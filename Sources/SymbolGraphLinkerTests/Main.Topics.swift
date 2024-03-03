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
        if  let tests:TestGroup = tests / "OneList" / "ImplicitTopic"
        {
            Self.run(tests: tests,
                markdown: """
                Overview overview overview

                ## Topics

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ## Discussion

                Details details details
                """,
                expected: """
                <p>Overview overview overview</p>
                <ul class='cards'>\
                <li><code>StopIt</code></li>\
                <li><code>DropIt</code></li>\
                <li><code>doc:GetAnotherTopic</code></li>\
                </ul>\
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>
                """,
                topics: [3])
        }
        if  let tests:TestGroup = tests / "OneList" / "OneTopic" / "Middle"
        {
            Self.run(tests: tests,
                markdown: """
                Overview overview overview

                ## Topics

                ### Chase Icon

                -   ``StopIt``
                -   ``DropIt``
                -   <doc:GetAnotherTopic>

                ## Discussion

                Details details details
                """,
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Chase%20Icon'><a href='#Chase%20Icon'>Chase Icon</a></h2>\
                <ul class='cards'>\
                <li><code>StopIt</code></li>\
                <li><code>DropIt</code></li>\
                <li><code>doc:GetAnotherTopic</code></li>\
                </ul>\
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>
                """,
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
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h2 id='Chase%20Icon'><a href='#Chase%20Icon'>Chase Icon</a></h2>\
                <ul class='cards'>\
                <li><code>StopIt</code></li>\
                <li><code>DropIt</code></li>\
                <li><code>doc:GetAnotherTopic</code></li>\
                </ul>
                """,
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
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h2 id='Chase%20Icon'><a href='#Chase%20Icon'>Chase Icon</a></h2>\
                <ul class='cards'>\
                <li><code>StopIt</code></li>\
                <li><code>DropIt</code></li>\
                <li><code>doc:GetAnotherTopic</code></li>\
                </ul>\
                <h2 id='Taylor%20Swift'><a href='#Taylor%20Swift'>Taylor Swift</a></h2>\
                <ul class='cards'>\
                <li><code>WeAreNeverEverGettingBackTogether</code></li>\
                <li><code>AllTooWell</code></li>\
                </ul>
                """,
                topics: [3, 2])
        }
        if  let tests:TestGroup = tests / "OneList" / "EmptyTopics"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Discussion

                Details details details

                ## Topics

                ### Ariana Grande

                ### Taylor Swift

                -   ``WeAreNeverEverGettingBackTogether``
                -   ``AllTooWell``

                ### Lana Del Rey

                """,
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h2 id='Ariana%20Grande'><a href='#Ariana%20Grande'>Ariana Grande</a></h2>\
                <h2 id='Taylor%20Swift'><a href='#Taylor%20Swift'>Taylor Swift</a></h2>\
                <ul class='cards'>\
                <li><code>WeAreNeverEverGettingBackTogether</code></li>\
                <li><code>AllTooWell</code></li>\
                </ul>\
                <h2 id='Lana%20Del%20Rey'><a href='#Lana%20Del%20Rey'>Lana Del Rey</a></h2>
                """,
                topics: [2])
        }
        if  let tests:TestGroup = tests / "Floating"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Discussion

                Details details details

                ### Taylor Swift

                -   ``WeAreNeverEverGettingBackTogether``
                -   ``AllTooWell``

                ### Lana Del Rey

                Just a regular paragraph.

                """,
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h3 id='Taylor%20Swift'><a href='#Taylor%20Swift'>Taylor Swift</a></h3>\
                <ul class='cards'>\
                <li><code>WeAreNeverEverGettingBackTogether</code></li>\
                <li><code>AllTooWell</code></li>\
                </ul>\
                <h3 id='Lana%20Del%20Rey'><a href='#Lana%20Del%20Rey'>Lana Del Rey</a></h3>\
                <p>Just a regular paragraph.</p>
                """,
                topics: [2])
        }
        if  let tests:TestGroup = tests / "FloatingSeeAlso"
        {
            Self.run(tests: tests,
                markdown:
                """
                Overview overview overview

                ## Discussion

                Details details details

                ### See also

                -   ``WeAreNeverEverGettingBackTogether``
                -   ``AllTooWell``

                """,
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h3 id='See%20also'><a href='#See%20also'>See also</a></h3>\
                <ul class='cards'>\
                <li><code>WeAreNeverEverGettingBackTogether</code></li>\
                <li><code>AllTooWell</code></li>\
                </ul>
                """,
                topics: [])
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
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Dua%20Lipa'><a href='#Dua%20Lipa'>Dua Lipa</a></h2>\
                <ul class='cards'>\
                <li><code>DanceTheNight</code></li>\
                </ul>\
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h2 id='Chase%20Icon'><a href='#Chase%20Icon'>Chase Icon</a></h2>\
                <ul class='cards'>\
                <li><code>StopIt</code></li>\
                <li><code>DropIt</code></li>\
                <li><code>doc:GetAnotherTopic</code></li>\
                </ul>\
                <h2 id='Taylor%20Swift'><a href='#Taylor%20Swift'>Taylor Swift</a></h2>\
                <ul class='cards'>\
                <li><code>WeAreNeverEverGettingBackTogether</code></li>\
                <li><code>AllTooWell</code></li>\
                </ul>
                """,
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
                expected: """
                <p>Overview overview overview</p>
                <h2 id='Dua%20Lipa'><a href='#Dua%20Lipa'>Dua Lipa</a></h2>\
                <p>Selected songs by Dua Lipa.</p>\
                <ul class='cards'>\
                <li><code>DanceTheNight</code></li>\
                </ul>\
                <h2 id='Discussion'><a href='#Discussion'>Discussion</a></h2>\
                <p>Details details details</p>\
                <h2 id='Chase%20Icon'><a href='#Chase%20Icon'>Chase Icon</a></h2>\
                <p>Lyrics from <em>Like Me</em>.</p>\
                <ul class='cards'>\
                <li><code>StopIt</code></li>\
                <li><code>DropIt</code></li>\
                <li><code>doc:GetAnotherTopic</code></li>\
                </ul>\
                <h2 id='Taylor%20Swift'><a href='#Taylor%20Swift'>Taylor Swift</a></h2>\
                <p>Selected songs by Taylor Swift.</p>\
                <aside class='note'>\
                <h3>Note</h3>\
                <p>These are from the original Red album.</p>\
                </aside>\
                <ul class='cards'>\
                <li><code>WeAreNeverEverGettingBackTogether</code></li>\
                <li><code>AllTooWell</code></li>\
                </ul>
                """,
                topics: [1, 3, 2])
        }
    }
}
