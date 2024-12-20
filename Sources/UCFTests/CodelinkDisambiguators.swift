import FNV1
import Testing
import UCF

@Suite
struct CodelinkDisambiguators:ParsingSuite
{
    typealias Format = UCF.Selector

    @Test
    static func Enum() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Fake [enum]")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Fake"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .filter(.enum))
    }
    @Test
    static func UncannyHash() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Fake [ENUM]")
        let hash:FNV24 = .init("ENUM", radix: 36)!

        #expect(link.base == .relative)
        #expect(link.path.components == ["Fake"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .hash(hash))
    }
    @Test
    static func ClassVar() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Fake.max [class var]")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Fake", "max"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .filter(.class_var))
    }
}
