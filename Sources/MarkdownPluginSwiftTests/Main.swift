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
                <span class='syntax-attribute'>@_spi</span>\
                (<span class='syntax-identifier'>testing</span>) \
                <span class='syntax-keyword'>mutating</span> \
                <span class='syntax-keyword'>func</span> \
                <span class='syntax-identifier'>transform</span>&lt;\
                <span class='syntax-typealias'>IndexOfResult</span>, \
                <span class='syntax-typealias'>ElementOfResult</span>\
                &gt;(\
                <span class='xi'></span>_ \
                <span class='syntax-binding'>a</span>: \
                (<span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Index</span>, \
                <span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Element</span>) \
                <span class='syntax-keyword'>throws</span> \
                -&gt; <span class='syntax-type'>IndexOfResult</span>?, \
                <span class='xi'></span><span class='syntax-identifier'>b</span> \
                <span class='syntax-binding'>b</span>: \
                (<span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Index</span>, \
                <span class='syntax-keyword'>Self</span>.\
                <span class='syntax-type'>Element</span>) \
                <span class='syntax-keyword'>throws</span> \
                -&gt; <span class='syntax-type'>ElementOfResult</span>?, \
                <span class='xi'></span><span class='syntax-identifier'>c</span>: \
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

            if  let tests:TestGroup = tests / "Malformed"
            {
                let decl:String = """
                init(__readers: UInt32, \
                __writers: UInt32,
                __wrphase_futex: UInt32,
                __writers_futex: UInt32,
                __pad3: UInt32,
                __pad4: UInt32,
                __cur_writer: Int32,
                __shared: Int32,
                __rwelision: Int8,
                __pad1: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8), \
                __pad2: UInt, \
                __flags: UInt32)
                """

                let expanded:Signature<Never>.Expanded = .init(decl)
                tests.expect("\(expanded.bytecode.safe)" ==? decl)
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
                <span class='xi'></span>\
                (Self.Index, Self.Element) throws -&gt; IndexOfResult?, \
                <span class='xi'></span><span class='syntax-identifier'>b</span>: \
                (Self.Index, Self.Element) throws -&gt; ElementOfResult?, \
                <span class='xi'></span><span class='syntax-identifier'>c</span>: \
                ((Self.Index, Self.Element) throws -&gt; ())?\
                <wbr>) rethrows -&gt; [(IndexOfResult, ElementOfResult)]
                """)
            }
        }

        if  let tests:TestGroup = tests / "InterestingKeywords"
        {
            if  let tests:TestGroup = tests / "Actor"
            {
                let decl:String = "actor MargotRobbie"

                var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
                let expanded:Signature<Never>.Expanded = .init(decl,
                    keywords: &keywords)

                tests.expect("\(expanded.bytecode.safe)" ==? decl)
                tests.expect(true: keywords.actor)
            }
            if  let tests:TestGroup = tests / "ClassSubscript"
            {
                let decl:String = "class subscript(index: Int) -> Int"

                var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
                let expanded:Signature<Never>.Expanded = .init(decl,
                    keywords: &keywords)

                tests.expect("\(expanded.bytecode.safe)" ==? decl)
                tests.expect(true: keywords.class)
            }
            if  let tests:TestGroup = tests / "ClassFunc"
            {
                let decl:String = "class func x() -> Int"

                var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
                let expanded:Signature<Never>.Expanded = .init(decl,
                    keywords: &keywords)

                tests.expect("\(expanded.bytecode.safe)" ==? decl)
                tests.expect(true: keywords.class)
            }
            if  let tests:TestGroup = tests / "ClassVar"
            {
                let decl:String = "class var x: Int { get }"

                var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
                let expanded:Signature<Never>.Expanded = .init(decl,
                    keywords: &keywords)

                tests.expect("\(expanded.bytecode.safe)" ==? decl)
                tests.expect(true: keywords.class)
            }
            if  let tests:TestGroup = tests / "FreestandingMacro"
            {
                let decl:String = """
                @freestanding(expression) macro line<T: ExpressibleByIntegerLiteral>() -> T
                """

                var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
                let expanded:Signature<Never>.Expanded = .init(decl,
                    keywords: &keywords)

                tests.expect("\(expanded.bytecode.safe)" ==? decl)
                tests.expect(true: keywords.freestanding)
            }
            if  let tests:TestGroup = tests / "AttachedMacro"
            {
                let decl:String = """
                @attached(member) @attached(conformance) public macro OptionSet<RawType>()
                """

                var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
                let expanded:Signature<Never>.Expanded = .init(decl,
                    keywords: &keywords)

                tests.expect("\(expanded.bytecode.safe)" ==? decl)
                tests.expect(true: keywords.attached)
            }
        }
    }
}
