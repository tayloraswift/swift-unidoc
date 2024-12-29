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
        #expect(link.suffix == .keywords(.enum))
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
        #expect(link.suffix == .keywords(.class_var))
    }
    @Test
    static func ClassVarRequirement() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Fake.max [class var, requirement]")
        #expect(link.base == .relative)
        #expect(link.path.components == ["Fake", "max"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [
                .init(keywords: .class_var, expected: true),
                .init(keywords: .requirement, expected: true)
            ],
            signature: nil)))
    }
    @Test
    static func ClassVarRequirementNegated() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Fake.max [class var: false, requirement: false]
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Fake", "max"])
        #expect(!link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [
                .init(keywords: .class_var, expected: false),
                .init(keywords: .requirement, expected: false)
            ],
            signature: nil)))
    }
    @Test
    static func Signature() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) (Int, _)
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [],
            signature: .function(["Int", nil]))))
    }
    @Test
    static func SignatureFull() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) (_, Int) -> Set<String>
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [],
            signature: .function([nil, "Int"], ["Set<String>"]))))
    }
    @Test
    static func SignatureReturns() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) -> Set<String>
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [],
            signature: .returns(["Set<String>"]))))
    }
    @Test
    static func SignatureProtocolComposition() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) (StringProtocol & Error, [Sendable & RandomAccessCollection<UInt8>])
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [],
            signature: .function([
                "StringProtocol&Error",
                "[Sendable&RandomAccessCollection<UInt8>]"
            ]))))
    }
    @Test
    static func SignatureVariadics() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) (String..., [Int: Set<T>]...)
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [],
            signature: .function(["String...", "[Int:Set<T>]..."]))))
    }
    @Test
    static func SignatureNoncopyable() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) (~Copyable & Sendable, ~(Copyable) & (Sendable))
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [],
            signature: .function(["~Copyable&Sendable", "~Copyable&Sendable"]))))
    }
    @Test
    static func All() throws
    {
        let link:UCF.Selector = try Self.roundtrip("""
            Foo.bar(_:_:) (_, Int) -> () [static func: false, requirement: true]
            """)
        #expect(link.base == .relative)
        #expect(link.path.components == ["Foo", "bar(_:_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .unidoc(.init(
            conditions: [
                .init(keywords: .static_func, expected: false),
                .init(keywords: .requirement, expected: true)
            ],
            signature: .function([nil, "Int"], []))))
    }
}
