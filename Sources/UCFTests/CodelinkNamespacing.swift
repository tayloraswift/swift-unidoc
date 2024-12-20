import Testing
import UCF

@Suite
struct CodelinkNamespacing:ParsingSuite
{
    typealias Format = UCF.Selector

    @Test
    static func Isolated() throws
    {
        let link:UCF.Selector = try Self.roundtrip("/Swift")
        #expect(link.base == .qualified)
        #expect(link.path.components == ["Swift"])
        #expect(link.path.visible == ["Swift"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Hidden() throws
    {
        let link:UCF.Selector = try Self.roundtrip("/Swift/Int")
        #expect(link.base == .qualified)
        #expect(link.path.components == ["Swift", "Int"])
        #expect(link.path.visible == ["Int"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Visible() throws
    {
        let link:UCF.Selector = try Self.roundtrip("/Swift.Int")
        #expect(link.base == .qualified)
        #expect(link.path.components == ["Swift", "Int"])
        #expect(link.path.visible == ["Swift", "Int"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func EmptyTrailingComponent() throws
    {
        let link:UCF.Selector = try Self.roundtrip("/Swift.Int/")
        #expect(link.base == .qualified)
        #expect(link.path.components == ["Swift", "Int"])
        #expect(link.path.visible == ["Swift", "Int"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
}
