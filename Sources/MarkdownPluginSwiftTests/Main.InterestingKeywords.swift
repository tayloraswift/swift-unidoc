import Signatures
import Testing_

@_spi(testable)
import MarkdownPluginSwift

extension Main
{
    struct InterestingKeywords
    {
    }
}
extension Main.InterestingKeywords:TestBattery
{
    static
    func run(tests:TestGroup)
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
        if  let tests:TestGroup = tests / "Final"
        {
            let decl:String = "final class C"

            var keywords:Signature<Never>.Expanded.InterestingKeywords = .init()
            let expanded:Signature<Never>.Expanded = .init(decl,
                keywords: &keywords)

            tests.expect("\(expanded.bytecode.safe)" ==? decl)
            tests.expect(true: keywords.final)
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
