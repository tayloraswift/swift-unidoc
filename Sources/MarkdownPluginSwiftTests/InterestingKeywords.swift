import Signatures
import Testing

@_spi(testable)
import MarkdownPluginSwift

@Suite
struct InterestingKeywords
{
    private
    var landmarks:SignatureLandmarks

    init()
    {
        self.landmarks = .init()
    }

    @Test mutating
    func Actor()
    {
        let decl:String = "actor MargotRobbie"

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.actor)
    }
    @Test mutating
    func Final()
    {
        let decl:String = "final class C"

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.final)
    }
    @Test mutating
    func ClassSubscript()
    {
        let decl:String = "class subscript(index: Int) -> Int"

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.class)
        #expect(self.landmarks.inputs == ["Int"])
        #expect(self.landmarks.output == ["Int"])
    }
    @Test mutating
    func ClassFunc()
    {
        let decl:String = "class func x() -> Int"

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.class)
        #expect(self.landmarks.inputs == [])
        #expect(self.landmarks.output == ["Int"])
    }
    @Test mutating
    func ClassVar()
    {
        let decl:String = "class var x: Int { get }"

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.class)
    }
    @Test mutating
    func FreestandingMacro()
    {
        let decl:String = """
        @freestanding(expression) macro line<T: ExpressibleByIntegerLiteral>() -> T
        """

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.freestanding)
    }
    @Test mutating
    func AttachedMacro()
    {
        let decl:String = """
        @attached(member) @attached(conformance) public macro OptionSet<RawType>()
        """

        let signature:Signature<Never>.Expanded = .init(decl,
            landmarks: &self.landmarks)

        #expect("\(signature.bytecode.safe)" == decl)
        #expect(self.landmarks.keywords.attached)
    }
}
