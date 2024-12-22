import Signatures
import Testing

@_spi(testable)
import MarkdownPluginSwift

@Suite
struct SignatureAbbreviation
{
    @Test
    static func GenericTypes()
    {
        let decl:String = """
        struct S<T, U> where T: Sequence, U: Hashable
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        struct S<T, U>
        """)
    }
    @Test
    static func GenericTypesWithConstrainedParameters()
    {
        let decl:String = """
        struct S<T : Sequence, U : Hashable>
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        struct S<T, U>
        """)
    }
    @Test
    static func LabeledFunc()
    {
        let decl:String = """
        func x<T>(a: T, b: Int) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(a: T, b: Int) -> Int
        """)
    }
    @Test
    static func LabeledFuncWithStaticModifier()
    {
        let decl:String = """
        static func x<T>(a: T, b: Int) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        static func x<T>(a: T, b: Int) -> Int
        """)
    }
    @Test
    static func LabeledFuncWithMutatingModifier()
    {
        let decl:String = """
        mutating func x<T>(a: T, b: Int) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(a: T, b: Int) -> Int
        """)
    }
    @Test
    static func LabeledFuncWithDefaultArguments()
    {
        let decl:String = """
        func x<T>(a: T = [1, 2, 3], b: Int = 1234) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(a: T, b: Int) -> Int
        """)
    }
    @Test
    static func UnlabeledFunc()
    {
        let decl:String = """
        func x<T>(_ a: T, _ b: Int) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(T, Int) -> Int
        """)
    }
    @Test
    static func UnlabeledFuncWithDefaultArguments()
    {
        let decl:String = """
        func x<T>(_ a: T = [1, 2, 3], _ b: Int = 1234) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(T, Int) -> Int
        """)
    }
    @Test
    static func UnlabeledFuncWithAttributedTypes()
    {
        let decl:String = """
        func x<T>(_: consuming T, _: inout Int) -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(consuming T, inout Int) -> Int
        """)
    }
    @Test
    static func UnlabeledFuncWithAttributes()
    {
        let decl:String = """
        func x<T>(_: @escaping (T) throws -> Int) rethrows -> Int
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        func x<T>(@escaping (T) throws -> Int) rethrows -> Int
        """)
    }

    @Test
    static func LabeledSubscript()
    {
        let decl:String = """
        subscript(a a: Int, b b: Int) -> Int { get }
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        subscript(a: Int, b: Int) -> Int
        """)
    }
    @Test
    static func UnlabeledSubscript()
    {
        let decl:String = """
        subscript(a: Int, b: Int) -> Int { get }
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        subscript(Int, Int) -> Int
        """)
    }
    @Test
    static func UnlabeledSubscriptWithConstraints()
    {
        let decl:String = """
        subscript<T>(a: T, b: Int) -> Int where T:Sequence, T.Element == Int { get }
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        subscript<T>(T, Int) -> Int
        """)
    }
    @Test
    static func Var()
    {
        let decl:String = """
        var x: Int { get }
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        var x: Int
        """)
    }
    @Test
    static func LabeledEnumCase()
    {
        let decl:String = """
        case x(a: Int, b: Int)
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        case x(a: Int, b: Int)
        """)
    }
    @Test
    static func UnlabeledEnumCase()
    {
        let decl:String = """
        case x(Int, Int)
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        case x(Int, Int)
        """)
    }
    @Test
    static func UnlabeledEnumCaseWithDefaultArguments()
    {
        let decl:String = """
        case x(Int = 0, Int = 1)
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        case x(Int, Int)
        """)
    }
    @Test
    static func UnlabeledEnumCaseWithInternalLabel()
    {
        let decl:String = """
        indirect case x(_ a: Int, _ b: Int)
        """

        let abridged:Signature<Never>.Abridged = .init(decl)

        #expect("\(abridged.bytecode.safe)" == """
        case x(Int, Int)
        """)
    }
}
