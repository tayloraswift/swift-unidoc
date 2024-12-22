import Signatures
import Testing

@_spi(testable)
import MarkdownPluginSwift

@Suite
struct InterestingKeywords
{
    @Test
    static func Actor()
    {
        let decl:String = "actor MargotRobbie"

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.actor)
    }
    @Test
    static func Final()
    {
        let decl:String = "final class C"

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.final)
    }
    @Test
    static func ClassSubscript()
    {
        let decl:String = "class subscript(index: Int) -> Int"

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.class)
    }
    @Test
    static func ClassFunc()
    {
        let decl:String = "class func x() -> Int"

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.class)
    }
    @Test
    static func ClassVar()
    {
        let decl:String = "class var x: Int { get }"

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.class)
    }
    @Test
    static func FreestandingMacro()
    {
        let decl:String = """
        @freestanding(expression) macro line<T: ExpressibleByIntegerLiteral>() -> T
        """

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.freestanding)
    }
    @Test
    static func AttachedMacro()
    {
        let decl:String = """
        @attached(member) @attached(conformance) public macro OptionSet<RawType>()
        """

        var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
        let expanded:Signature<Never>.Expanded = .init(decl,
            keywords: &keywords)

        #expect("\(expanded.bytecode.safe)" == decl)
        #expect(keywords.attached)
    }
}
