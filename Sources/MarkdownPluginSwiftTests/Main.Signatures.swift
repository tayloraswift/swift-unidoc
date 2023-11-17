import HTML
import MarkdownRendering
import Signatures
import Testing

@_spi(testable)
import MarkdownPluginSwift

extension Main
{
    struct Signatures
    {
    }
}
extension Main.Signatures:TestBattery
{
    static
    func run(tests:TestGroup)
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

            let abridged:Signature<Never>.Abridged = .init(decl)
            tests.expect("\(abridged.bytecode.safe)" ==? """
            func transform<IndexOfResult, ElementOfResult>(\
            (Self.Index, Self.Element) throws -> IndexOfResult?, \
            b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
            c: ((Self.Index, Self.Element) throws -> ())?\
            ) rethrows -> [(IndexOfResult, ElementOfResult)]
            """)

            let html:HTML = .init { $0 += expanded.bytecode.safe }

            tests.expect("\(html)" ==? """
            <span class='xa'>@_spi</span>\
            (<span class='xv'>testing</span>) \
            <span class='xk'>mutating</span> \
            <span class='xk'>func</span> \
            <span class='xv'>transform</span>&lt;\
            <span class='xu'>IndexOfResult</span>, \
            <span class='xu'>ElementOfResult</span>\
            &gt;(\
            <span class='xi'></span>_ \
            <span class='xb'>a</span>: \
            (<span class='xk'>Self</span>.\
            <span class='xt'>Index</span>, \
            <span class='xk'>Self</span>.\
            <span class='xt'>Element</span>) \
            <span class='xk'>throws</span> \
            -&gt; <span class='xt'>IndexOfResult</span>?, \
            <span class='xi'></span><span class='xv'>b</span> \
            <span class='xb'>b</span>: \
            (<span class='xk'>Self</span>.\
            <span class='xt'>Index</span>, \
            <span class='xk'>Self</span>.\
            <span class='xt'>Element</span>) \
            <span class='xk'>throws</span> \
            -&gt; <span class='xt'>ElementOfResult</span>?, \
            <span class='xi'></span><span class='xv'>c</span>: \
            ((<span class='xk'>Self</span>.\
            <span class='xt'>Index</span>, \
            <span class='xk'>Self</span>.\
            <span class='xt'>Element</span>) \
            <span class='xk'>throws</span> -&gt; ())? = \
            <span class='xk'>nil</span>\
            <wbr>) <span class='xk'>rethrows</span> -&gt; \
            [(<span class='xt'>IndexOfResult</span>, \
            <span class='xt'>ElementOfResult</span>)] \
            <span class='xk'>where</span> \
            <span class='xt'>IndexOfResult</span>: \
            <span class='xt'>Strideable</span>, \
            <span class='xt'>ElementOfResult</span>: \
            <span class='xt'>Sendable</span>
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

        if  let tests:TestGroup = tests / "Abbreviation"
        {
            if  let tests:TestGroup = tests / "GenericTypes"
            {
                let decl:String = """
                struct S<T, U> where T: Sequence, U: Hashable
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                struct S<T, U>
                """)
            }
            if  let tests:TestGroup = tests / "GenericTypesWithConstrainedParameters"
            {
                let decl:String = """
                struct S<T : Sequence, U : Hashable>
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                struct S<T, U>
                """)
            }
            if  let tests:TestGroup = tests / "LabeledFunc"
            {
                let decl:String = """
                func x<T>(a: T, b: Int) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(a: T, b: Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "LabeledFuncWithStaticModifier"
            {
                let decl:String = """
                static func x<T>(a: T, b: Int) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                static func x<T>(a: T, b: Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "LabeledFuncWithMutatingModifier"
            {
                let decl:String = """
                mutating func x<T>(a: T, b: Int) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(a: T, b: Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "LabeledFuncWithDefaultArguments"
            {
                let decl:String = """
                func x<T>(a: T = [1, 2, 3], b: Int = 1234) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(a: T, b: Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledFunc"
            {
                let decl:String = """
                func x<T>(_ a: T, _ b: Int) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(T, Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledFuncWithDefaultArguments"
            {
                let decl:String = """
                func x<T>(_ a: T = [1, 2, 3], _ b: Int = 1234) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(T, Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledFuncWithAttributedTypes"
            {
                let decl:String = """
                func x<T>(_: consuming T, _: inout Int) -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(consuming T, inout Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledFuncWithAttributes"
            {
                let decl:String = """
                func x<T>(_: @escaping (T) throws -> Int) rethrows -> Int
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                func x<T>(@escaping (T) throws -> Int) rethrows -> Int
                """)
            }

            if  let tests:TestGroup = tests / "LabeledSubscript"
            {
                let decl:String = """
                subscript(a a: Int, b b: Int) -> Int { get }
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                subscript(a: Int, b: Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledSubscript"
            {
                let decl:String = """
                subscript(a: Int, b: Int) -> Int { get }
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                subscript(Int, Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledSubscriptWithConstraints"
            {
                let decl:String = """
                subscript<T>(a: T, b: Int) -> Int where T:Sequence, T.Element == Int { get }
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                subscript<T>(T, Int) -> Int
                """)
            }
            if  let tests:TestGroup = tests / "Var"
            {
                let decl:String = """
                var x: Int { get }
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                var x: Int
                """)
            }
            if  let tests:TestGroup = tests / "LabeledEnumCase"
            {
                let decl:String = """
                case x(a: Int, b: Int)
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                case x(a: Int, b: Int)
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledEnumCase"
            {
                let decl:String = """
                case x(Int, Int)
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                case x(Int, Int)
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledEnumCaseWithDefaultArguments"
            {
                let decl:String = """
                case x(Int = 0, Int = 1)
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                case x(Int, Int)
                """)
            }
            if  let tests:TestGroup = tests / "UnlabeledEnumCaseWithInternalLabel"
            {
                let decl:String = """
                indirect case x(_ a: Int, _ b: Int)
                """

                let abridged:Signature<Never>.Abridged = .init(decl)

                tests.expect("\(abridged.bytecode.safe)" ==? """
                case x(Int, Int)
                """)
            }
        }
        if  let tests:TestGroup = tests / "Abridged" / "Complex"
        {
            let decl:String = """
            func transform<IndexOfResult, ElementOfResult>(\
            _: (Self.Index, Self.Element) throws -> IndexOfResult?, \
            b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
            c: ((Self.Index, Self.Element) throws -> ())?\
            ) rethrows -> [(IndexOfResult, ElementOfResult)]
            """

            let abridged:Signature<Never>.Abridged = .init(decl)

            tests.expect("\(abridged.bytecode.safe)" ==? """
            func transform<IndexOfResult, ElementOfResult>(\
            (Self.Index, Self.Element) throws -> IndexOfResult?, \
            b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
            c: ((Self.Index, Self.Element) throws -> ())?\
            ) rethrows -> [(IndexOfResult, ElementOfResult)]
            """)

            let html:HTML = .init { $0 += abridged.bytecode.safe }

            tests.expect("\(html)" ==? """
            func <span class='xv'>transform</span>&lt;\
            IndexOfResult, ElementOfResult\
            &gt;(\
            <span class='xi'></span>\
            (Self.Index, Self.Element) throws -&gt; IndexOfResult?, \
            <span class='xi'></span><span class='xv'>b</span>: \
            (Self.Index, Self.Element) throws -&gt; ElementOfResult?, \
            <span class='xi'></span><span class='xv'>c</span>: \
            ((Self.Index, Self.Element) throws -&gt; ())?\
            <wbr>) rethrows -&gt; [(IndexOfResult, ElementOfResult)]
            """)
        }

        if  let tests:TestGroup = tests / "Abridged" / "UnlabeledArguments"
        {
            let decl:String = """
            func tion(_: Int, _ y: String.Index)
            """

            let abridged:Signature<Never>.Abridged = .init(decl)

            tests.expect("\(abridged.bytecode.safe)" ==? """
            func tion(Int, String.Index)
            """)

            let html:HTML = .init { $0 += abridged.bytecode.safe }

            tests.expect("\(html)" ==? """
            func <span class='xv'>tion</span>(\
            <span class='xi'></span>Int, \
            <span class='xi'></span>String.Index\
            <wbr>)
            """)
        }
        if  let tests:TestGroup = tests / "Abridged" / "Init"
        {
            let decl:String = """
            init(_ collection: Mongo.Collection, \
            writeConcern: Mongo.Create<Mode>.WriteConcern?, \
            with encode: (inout Mongo.Create<Mode>) throws -> ()) rethrows
            """

            let abridged:Signature<Never>.Abridged = .init(decl)

            tests.expect("\(abridged.bytecode.safe)" ==? """
            init(Mongo.Collection, \
            writeConcern: Mongo.Create<Mode>.WriteConcern?, \
            with: (inout Mongo.Create<Mode>) throws -> ()) rethrows
            """)

            let html:HTML = .init { $0 += abridged.bytecode.safe }

            tests.expect("\(html)" ==? """
            <span class='xv'>init</span>(\
            <span class='xi'></span>Mongo.Collection, \
            <span class='xi'></span><span class='xv'>writeConcern</span>: \
            Mongo.Create&lt;Mode&gt;.WriteConcern?, \
            <span class='xi'></span><span class='xv'>with</span>: \
            (inout Mongo.Create&lt;Mode&gt;) throws -&gt; ()\
            <wbr>) rethrows
            """)
        }
    }
}
