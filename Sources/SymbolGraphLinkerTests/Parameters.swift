import Testing

@Suite
struct Parameters:MarkdownTestSuite
{
    @Test
    static func None() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <p>Details details details</p>
            """)
    }
    @Test
    static func Empty() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <p>Details details details</p>
            """)
    }
    @Test
    static func One() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                - first: Description for first parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Many() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                - first: Description for first parameter
                - second: Description for second parameter
                - third: Description for third parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            <dt id='sp:second'><a href='#sp:second'>second</a></dt>\
            <dd><p>Description for second parameter</p></dd>\
            <dt id='sp:third'><a href='#sp:third'>third</a></dt>\
            <dd><p>Description for third parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Formatting() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - **Parameters**:
                - `first`:
                Description for first parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func LineContinuations() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                - first:
                Description for first parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Indentation() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                - first:
                    Description for first parameter
                -   second:
                    Description for second parameter

                -   third    :

                      Description for third parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            <dt id='sp:second'><a href='#sp:second'>second</a></dt>\
            <dd><p>Description for second parameter</p></dd>\
            <dt id='sp:third'><a href='#sp:third'>third</a></dt>\
            <dd><p>Description for third parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Discussion() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                Discussion about parameters in general
                - first:
                Description for first parameter

                More discussion about parameters in general

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <p>Discussion about parameters in general</p>\
            <p>More discussion about parameters in general</p>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func MultipleLists() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                Discussion about parameters in general
                - first:
                Description for first parameter
            - Parameters:
                More discussion about parameters in general
                - second:
                Description for second parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <p>Discussion about parameters in general</p>\
            <p>More discussion about parameters in general</p>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            <dt id='sp:second'><a href='#sp:second'>second</a></dt>\
            <dd><p>Description for second parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
    @Test
    static func Collation() throws
    {
        try Self.test(
            markdown: """
            Overview overview overview
            - Parameters:
                Discussion about parameters in general
                - first:
                Description for first parameter
            - Parameter second:
                Description for second parameter

            Details details details
            """,
            expected: """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2 id='ss:parameters'><a href='#ss:parameters'>Parameters</a></h2>\
            <p>Discussion about parameters in general</p>\
            <dl>\
            <dt id='sp:first'><a href='#sp:first'>first</a></dt>\
            <dd><p>Description for first parameter</p></dd>\
            <dt id='sp:second'><a href='#sp:second'>second</a></dt>\
            <dd><p>Description for second parameter</p></dd>\
            </dl>\
            </section>\
            <p>Details details details</p>
            """)
    }
}
