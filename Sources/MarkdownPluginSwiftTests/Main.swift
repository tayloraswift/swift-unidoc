import HTML
import MarkdownRendering
import Signatures
import Testing

@_spi(testable)
import MarkdownPluginSwift

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "Signatures"
        {

            if  let tests:TestGroup = tests / "Expanded"
            {
                let decl:String = """
                @_spi(testing) mutating func transform<IndexOfResult, ElementOfResult>(\
                _ a: (Self.Index, Self.Element) throws -> IndexOfResult?, \
                b b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
                c: ((Self.Index, Self.Element) throws -> ())? = nil\
                ) rethrows -> [(IndexOfResult, ElementOfResult)] \
                where IndexOfResult: Strideable, ElementOfResult: Sendable
                """

                let expanded:Signature<Never>.Expanded = .init(decl)
                tests.expect("\(expanded.bytecode.safe)" ==? decl)

                let html:HTML = .init { $0 += expanded.bytecode.safe }

                tests.expect("\(html)" ==? """
                <span class='syntax-attribute'>@</span><span class='syntax-keyword'>_spi</span>\
                (<span class='syntax-identifier'>testing</span>) \
                <span class='syntax-keyword'>mutating</span> \
                <span class='syntax-keyword'>func</span> \
                <span class='syntax-identifier'>transform</span>&lt;\
                <span class='syntax-typealias'>IndexOfResult</span>, \
                <span class='syntax-typealias'>ElementOfResult</span>\
                &gt;(\
                <wbr><span class='syntax-label'>_</span> \
                <span class='syntax-identifier'>a</span>: \
                (<span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Index</span>, \
                <span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Element</span>) \
                <span class='syntax-keyword'>throws</span> \
                -&gt; <span class='syntax-type'>IndexOfResult</span>?, \
                <wbr><span class='syntax-label'>b</span> \
                <span class='syntax-identifier'>b</span>: \
                (<span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Index</span>, \
                <span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Element</span>) \
                <span class='syntax-keyword'>throws</span> \
                -&gt; <span class='syntax-type'>ElementOfResult</span>?, \
                <wbr><span class='syntax-label'>c</span>: \
                ((<span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Index</span>, \
                <span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Element</span>) \
                <span class='syntax-keyword'>throws</span> -&gt; ())? = \
                <span class='syntax-keyword'>nil</span>\
                <wbr>) <span class='syntax-keyword'>rethrows</span> -&gt; \
                [(<span class='syntax-type'>IndexOfResult</span>, \
                <span class='syntax-type'>ElementOfResult</span>)] \
                <span class='syntax-keyword'>where</span> \
                <span class='syntax-type'>IndexOfResult</span>: \
                <span class='syntax-type'>Strideable</span>, \
                <span class='syntax-type'>ElementOfResult</span>: \
                <span class='syntax-type'>Sendable</span>
                """)
            }


            if  let tests:TestGroup = tests / "Abridged"
            {
                let text:String = """
                func transform<IndexOfResult, ElementOfResult>(\
                (Self.Index, Self.Element) throws -> IndexOfResult?, \
                b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
                c: ((Self.Index, Self.Element) throws -> ())?\
                ) rethrows -> [(IndexOfResult, ElementOfResult)]
                """

                let abridged:Signature<Never>.Abridged = .init(text)

                tests.expect("\(abridged.bytecode.safe)" ==? text)

                let html:HTML = .init { $0 += abridged.bytecode.safe }

                tests.expect("\(html)" ==? """
                func <span class='syntax-identifier'>transform</span>&lt;\
                IndexOfResult, ElementOfResult\
                &gt;(\
                <wbr>(Self.Index, Self.Element) throws -&gt; IndexOfResult?, \
                <wbr><span class='syntax-label'>b</span>: \
                (Self.Index, Self.Element) throws -&gt; ElementOfResult?, \
                <wbr><span class='syntax-label'>c</span>: \
                ((Self.Index, Self.Element) throws -&gt; ())?\
                <wbr>) rethrows -&gt; [(IndexOfResult, ElementOfResult)]
                """)
            }
        }
    }
}