import HTML
import MarkdownParsing
import MarkdownRendering
import MarkdownSemantics
import Testing

@main
enum Main:SyncTests
{
    private static
    func run(tests:TestGroup, markdown:String, expected:String)
    {
        tests.do
        {
            let documentation:MarkdownDocumentation = .init(parsing: markdown,
                as: SwiftFlavoredMarkdown.self)
            let binary:MarkdownBinary = .init(from: documentation)
            let html:HTML = try .init
            {
                if let error:MarkdownExecutionError = binary.render(to: &$0)
                {
                    throw error
                }
            }

            tests.expect(html.description ==? expected)
        }
    }

    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "parameters"
        {
            if  let tests:TestGroup = tests / "none"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview

                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "empty"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - Parameters:

                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "one"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - Parameters:
                        - first: Description for first parameter
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "many"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - Parameters:
                        - first: Description for first parameter
                        - second: Description for second parameter
                        - third: Description for third parameter
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    <dt>second</dt>\
                    <dd><p>Description for second parameter</p></dd>\
                    <dt>third</dt>\
                    <dd><p>Description for third parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "formatting"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - **Parameters**:
                        - `first`:
                        Description for first parameter
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "line-continuations"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - Parameters:
                        - first:
                        Description for first parameter
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "indentation"
            {
                Self.run(tests: tests,
                    markdown:
                    """
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
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    <dt>second</dt>\
                    <dd><p>Description for second parameter</p></dd>\
                    <dt>third</dt>\
                    <dd><p>Description for third parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "discussion"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - Parameters:
                        Discussion about parameters in general
                        - first:
                        Description for first parameter
                    
                        More discussion about parameters in general
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <p>Discussion about parameters in general</p>\
                    <p>More discussion about parameters in general</p>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "multiple-lists"
            {
                Self.run(tests: tests,
                    markdown:
                    """
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
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <p>Discussion about parameters in general</p>\
                    <p>More discussion about parameters in general</p>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    <dt>second</dt>\
                    <dd><p>Description for second parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "collation"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    - Parameters:
                        Discussion about parameters in general
                        - first:
                        Description for first parameter
                    - Parameter second:
                        Description for second parameter
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <p>Discussion about parameters in general</p>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for first parameter</p></dd>\
                    <dt>second</dt>\
                    <dd><p>Description for second parameter</p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
        }
        if  let tests:TestGroup = tests / "lists"
        {
            if  let tests:TestGroup = tests / "asides"
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
            if  let tests:TestGroup = tests / "formatting"
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
        if  let tests:TestGroup = tests / "blockquote"
        {
            if  let tests:TestGroup = tests / "literal"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > equality implies substitutability and u r irreplaceable 💝
                        — barbie
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <blockquote>\
                    <p>equality implies substitutability and u r irreplaceable 💝 — barbie</p>\
                    </blockquote>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "literal" / "colon"
            {
                //  Apostrophe will become a curly quote, due to cmark-gfm smart punctuation.
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > Miranda: Don't be ridiculous, Andrea. Everybody wants this.
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <blockquote>\
                    <p>Miranda: Don’t be ridiculous, Andrea. Everybody wants this.</p>\
                    </blockquote>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "asides"
            {
                Self.run(tests: tests,
                    markdown:
                    """
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
                    expected:
                    """
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
            if  let tests:TestGroup = tests / "formatting"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > **Important**:
                        A barbie princess is not the same thing as a
                        princess barbie.
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <aside class='important'>\
                    <h3>Important</h3>\
                    <p>A barbie princess is not the same thing as a princess barbie.</p>\
                    </aside>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "capitalization"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > IMPORTANT: i am an important businessman.
                        A VERY IMPORTANT BUSINESSMAN
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <aside class='important'>\
                    <h3>Important</h3>\
                    <p>i am an important businessman. A VERY IMPORTANT BUSINESSMAN</p>\
                    </aside>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "wordbreaks"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > nonmutating variant: Humans on top!

                    > non mutatingvariant: Humans on top!

                    > nonmutatingvariant: Humans on top!

                    > non-mutating-variant: Humans on top!
                    
                    Details details details
                    """,
                    expected:
                    """
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
            if  let tests:TestGroup = tests / "standalone"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    >   Important:
                        A barbie princess is not the same thing as a
                        princess barbie.
                    
                    Details details details
                    """,
                    expected:
                    """

                    <aside class='important'>\
                    <h3>Important</h3>\
                    <p>A barbie princess is not the same thing as a princess barbie.</p>\
                    </aside>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "parameters"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > Parameters:
                        Discussion about parameters in general.
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <p>Discussion about parameters in general.</p>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "parameter" / "one"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > Parameter parameter:
                        Description for `parameter`
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>parameter</dt>\
                    <dd><p>Description for <code>parameter</code></p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "parameter" / "many"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > Parameter first:
                        Description for `first`
                    
                    Details details details

                    > Parameter second:
                        Description for `second`
                    
                    Even more details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>first</dt>\
                    <dd><p>Description for <code>first</code></p></dd>\
                    <dt>second</dt>\
                    <dd><p>Description for <code>second</code></p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>\
                    <p>Even more details</p>
                    """)
            }
            if  let tests:TestGroup = tests / "parameter" / "formatting"
            {
                Self.run(tests: tests,
                    markdown:
                    """
                    Overview overview overview
                    > **Parameter** `parameter`:
                        Description for `parameter`
                    
                    Details details details
                    """,
                    expected:
                    """
                    <p>Overview overview overview</p>\

                    <section class='parameters'>\
                    <h2>Parameters</h2>\
                    <dl>\
                    <dt>parameter</dt>\
                    <dd><p>Description for <code>parameter</code></p></dd>\
                    </dl>\
                    </section>\
                    <p>Details details details</p>
                    """)
            }
        }
        if  let tests:TestGroup = tests / "multiple-list-items"
        {
            let html:String =
            """
            <p>Overview overview overview</p>\

            <section class='parameters'>\
            <h2>Parameters</h2>\
            <p>Discussion about parameters in general.</p>\
            <dl>\
            <dt>first</dt>\
            <dd><p>Description for first parameter</p></dd>\
            </dl>\
            </section>\
            <section class='returns'>\
            <h2>Returns</h2>\
            <p>Discussion about return value.</p>\
            </section>\
            <aside class='warning'>\
            <h3>Warning</h3>\
            <p>This function is known by the state of california to cause cancer!</p>\
            </aside>\
            <p>Details details details</p>
            """
            if  let tests:TestGroup = tests / "basic"
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
            if  let tests:TestGroup = tests / "interlopers"
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
            if  let tests:TestGroup = tests / "reordering"
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
}
