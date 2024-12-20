import FNV1
import Testing
import UCF

@Suite
struct CodelinkLegacyDocC:ParsingSuite
{
    typealias Format = UCF.Selector

    @Test
    static func Slashes() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/Color")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "Color"])
        #expect(link.path.visible == ["Color"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Filter() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/Color-swift.enum")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "Color"])
        #expect(link.path.visible == ["Color"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .filter(.enum))
    }
    @Test
    static func FilterInterior() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth-swift.struct/Color")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "Color"])
        #expect(link.path.visible == ["Color"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func FilterLegacy() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/Color-swift.class")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "Color"])
        #expect(link.path.visible == ["Color"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .legacy(.class, nil))
    }
    @Test
    static func FilterAndHash() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/Color-swift.struct-4ko57")
        let hash:FNV24 = .init("4ko57", radix: 36)!

        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "Color"])
        #expect(link.path.visible == ["Color"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .legacy(.struct, hash))
    }
    @Test
    static func Hash() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)-4ko57")
        let hash:FNV24 = .init("4ko57", radix: 36)!

        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.visible == ["update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .hash(hash))
    }
    @Test
    static func HashMinus() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/-(_:)-4ko57")
        let hash:FNV24 = .init("4ko57", radix: 36)!

        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "-(_:)"])
        #expect(link.path.visible == ["-(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .hash(hash))
    }
    @Test
    static func HashSlingingSlasher() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth//(_:)-4ko57")
        let hash:FNV24 = .init("4ko57", radix: 36)!

        #expect(link.base == .relative)
        #expect(link.path.components == ["Sloth", "/(_:)"])
        #expect(link.path.visible == ["/(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .hash(hash))
    }
}
