import Testing
import UCF

@Suite
struct CodelinkPaths:ParsingSuite
{
    typealias Format = UCF.Selector

    @Test
    static func DotDot() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Unicode.Scalar.value")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Unicode", "Scalar", "value"])
        #expect(link.path.visible == ["Unicode", "Scalar", "value"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func SlashDot() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Unicode/Scalar.value")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Unicode", "Scalar", "value"])
        #expect(link.path.visible == ["Scalar", "value"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func DotSlash() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Unicode.Scalar/value")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Unicode", "Scalar", "value"])
        #expect(link.path.visible == ["value"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func SlashSlash() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Unicode/Scalar/value")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Unicode", "Scalar", "value"])
        #expect(link.path.visible == ["value"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func SingleCharacter() throws
    {
        let link:UCF.Selector = try Self.roundtrip("x")
        #expect(link.base == .relative)
        #expect(link.path.components == ["x"])
        #expect(link.path.visible == ["x"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }

    @Test
    static func Real1() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real...(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "..(_:_:)"])
        #expect(link.path.visible == ["Real", "..(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real2() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real/..(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "..(_:_:)"])
        #expect(link.path.visible == ["..(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real3() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real....(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "...(_:_:)"])
        #expect(link.path.visible == ["Real", "...(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real4() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real/...(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "...(_:_:)"])
        #expect(link.path.visible == ["...(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real5() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real./(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "/(_:_:)"])
        #expect(link.path.visible == ["Real", "/(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real6() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real//(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "/(_:_:)"])
        #expect(link.path.visible == ["/(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real7() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real../.(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "./.(_:_:)"])
        #expect(link.path.visible == ["Real", "./.(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func Real8() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real/./.(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "./.(_:_:)"])
        #expect(link.path.visible == ["./.(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func EmptyTrailingParentheses() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real.init()")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "init"])
        #expect(link.path.visible == ["Real", "init"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func EmptyTrailingComponent() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Real.init/")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Real", "init"])
        #expect(link.path.visible == ["Real", "init"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func DivisionOperator() throws
    {
        let link:UCF.Selector = try Self.roundtrip("/(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["/(_:_:)"])
        #expect(link.path.visible == ["/(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func CustomOperator() throws
    {
        let link:UCF.Selector = try Self.roundtrip("/-/(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["/-/(_:_:)"])
        #expect(link.path.visible == ["/-/(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
    @Test
    static func ClosedRangeOperator() throws
    {
        let link:UCF.Selector = try Self.roundtrip("...(_:_:)")
        #expect(link.base == .relative)
        #expect(link.path.components == ["...(_:_:)"])
        #expect(link.path.visible == ["...(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == nil)
    }
}
