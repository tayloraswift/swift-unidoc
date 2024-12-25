import HTML
import MarkdownRendering
import Signatures
import Testing

@_spi(testable)
import MarkdownPluginSwift

@Suite
struct Signatures
{
    @Test
    static func Expanded()
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
        #expect("\(expanded.bytecode.safe)" == decl)

        let abridged:Signature<Never>.Abridged = .init(decl)
        #expect("\(abridged.bytecode.safe)" == """
        func transform<IndexOfResult, ElementOfResult>(\
        (Self.Index, Self.Element) throws -> IndexOfResult?, \
        b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
        c: ((Self.Index, Self.Element) throws -> ())?\
        ) rethrows -> [(IndexOfResult, ElementOfResult)]
        """)

        let html:HTML = .init { $0 += expanded.bytecode.safe }

        #expect("\(html)" == """
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

    /// This test checks that the signature parser can correct the upstream bug in
    /// lib/SymbolGraphGen: https://github.com/swiftlang/swift/issues/78343
    @Test
    static func ExpandedWithSelf()
    {
        let decl:String = """
        func sum(with other: `Self`) -> Int
        """

        let expanded:Signature<Never>.Expanded = .init(decl)
        #expect("\(expanded.bytecode.safe)" == """
        func sum(with other: Self) -> Int
        """)

        let abridged:Signature<Never>.Abridged = .init(decl)
        #expect("\(abridged.bytecode.safe)" == """
        func sum(with: Self) -> Int
        """)
    }
    @Test
    static func ExpandedWithInoutSelf()
    {
        let decl:String = """
        func sum(with other: inout `Self`) -> Int
        """

        let expanded:Signature<Never>.Expanded = .init(decl)
        #expect("\(expanded.bytecode.safe)" == """
        func sum(with other: inout Self) -> Int
        """)

        let abridged:Signature<Never>.Abridged = .init(decl)
        #expect("\(abridged.bytecode.safe)" == """
        func sum(with: inout Self) -> Int
        """)
    }

    @Test
    static func ExpandedWithResultBuilders()
    {
        let decl:String = """
        init(@Builder<A<B, C>, D> builder:() -> Handler)
        """

        let expanded:Signature<Never>.Expanded = .init(decl, linkBoundaries: [
            6, 13,
            14, 15,
            16, 17,
            19, 20,
            23, 24,
        ])
        #expect("\(expanded.bytecode.safe)" == decl)

        let abridged:Signature<Never>.Abridged = .init(decl)
        #expect("\(abridged.bytecode.safe)" == """
        init(builder:() -> Handler)
        """)

        let html:HTML = .init { $0 += expanded.bytecode.safe }

        #expect("\(html)" == """
        <span class='xk'>init</span>(\
        <span class='xi'></span>\
        <span class='xa'>@</span>\
        <span class='xa'>Builder</span>\
        <span class='xa'>&lt;</span>\
        <span class='xa'>A</span>\
        <span class='xa'>&lt;</span>\
        <span class='xa'>B</span>\
        <span class='xa'>, </span>\
        <span class='xa'>C</span>\
        <span class='xa'>&gt;, </span>\
        <span class='xa'>D</span>\
        <span class='xa'>&gt;</span> \
        <span class='xv'>builder</span>:() -&gt; <span class='xt'>Handler</span><wbr>)
        """)
    }

    @Test
    static func Malformed()
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
        #expect("\(expanded.bytecode.safe)" == decl)
    }

    @Test
    static func AbridgedComplex()
    {
        let decl:String = """
        func transform<IndexOfResult, ElementOfResult>(\
        _: (Self.Index, Self.Element) throws -> IndexOfResult?, \
        b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
        c: ((Self.Index, Self.Element) throws -> ())?\
        ) rethrows -> [(IndexOfResult, ElementOfResult)]
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func transform<IndexOfResult, ElementOfResult>(\
        (Self.Index, Self.Element) throws -> IndexOfResult?, \
        b: (Self.Index, Self.Element) throws -> ElementOfResult?, \
        c: ((Self.Index, Self.Element) throws -> ())?\
        ) rethrows -> [(IndexOfResult, ElementOfResult)]
        """)

        let html:HTML = .init { $0 += abridged.bytecode.safe }

        #expect("\(html)" == """
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

    @Test
    static func AbridgedUnlabeledArguments()
    {
        let decl:String = """
        func tion(_: Int, _ y: String.Index)
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func tion(Int, String.Index)
        """)

        let html:HTML = .init { $0 += abridged.bytecode.safe }

        #expect("\(html)" == """
        func <span class='xv'>tion</span>(\
        <span class='xi'></span>Int, \
        <span class='xi'></span>String.Index\
        <wbr>)
        """)
    }

    @Test
    static func AbridgedInit()
    {
        let decl:String = """
        init(_ collection: Mongo.Collection, \
        writeConcern: Mongo.Create<Mode>.WriteConcern?, \
        with encode: (inout Mongo.Create<Mode>) throws -> ()) rethrows
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        init(Mongo.Collection, \
        writeConcern: Mongo.Create<Mode>.WriteConcern?, \
        with: (inout Mongo.Create<Mode>) throws -> ()) rethrows
        """)

        let html:HTML = .init { $0 += abridged.bytecode.safe }

        #expect("\(html)" == """
        <span class='xv'>init</span>(\
        <span class='xi'></span>Mongo.Collection, \
        <span class='xi'></span><span class='xv'>writeConcern</span>: \
        Mongo.Create&lt;Mode&gt;.WriteConcern?, \
        <span class='xi'></span><span class='xv'>with</span>: \
        (inout Mongo.Create&lt;Mode&gt;) throws -&gt; ()\
        <wbr>) rethrows
        """)
    }

    @Test
    static func AbridgedBackDeployed()
    {
        let decl:String = """
        @backDeployed(before: macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0)

        nonisolated func assertIsolated(\
        _ message: @autoclosure () -> String = String(), \
        file: StaticString = #fileID, \
        line: UInt = #line)
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        let rendered:HTML = .init { $0 += abridged.bytecode.safe }
        let expected:HTML = .init
        {
            $0 += "nonisolated func "
            $0[.span] { $0.class = "xv" } = "assertIsolated"
            $0 += "("
            $0[.span] { $0.class = "xi" }
            $0 += "@autoclosure () -> String, "
            $0[.span] { $0.class = "xi" }
            $0[.span] { $0.class = "xv" } = "file"
            $0 += ": StaticString, "
            $0[.span] { $0.class = "xi" }
            $0[.span] { $0.class = "xv" } = "line"
            $0 += ": UInt"
            $0[.wbr]
            $0 += ")"
        }

        #expect("\(rendered)" == "\(expected)")
    }
}
