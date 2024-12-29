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
        #expect(link.suffix == .keywords(.enum))
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

    @Test
    static func PatternWithArguments1() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)-(_)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.function([nil])))
    }

    @Test
    static func PatternWithArguments2() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)-(Int)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.function(["Int"])))
    }

    @Test
    static func PatternWithArguments3() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)-(_,String,_)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.function([nil, "String", nil])))
    }

    @Test
    static func PatternReturnsTuple1() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->(_,_)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns([nil, nil])))
    }

    @Test
    static func PatternReturnsTuple2() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->(Double,_)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns(["Double", nil])))
    }

    @Test
    static func PatternReturnsTuple3() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->(Double,Int)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns(["Double", "Int"])))
    }

    @Test
    static func PatternReturnsTuple4() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->(_,Int)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns([nil, "Int"])))
    }

    @Test
    static func PatternReturnsVoid() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->()")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns([])))
    }

    @Test
    static func PatternReturnsDouble() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->Double")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns(["Double"])))
    }

    @Test
    static func PatternReturnsWildcard() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->_")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns([nil])))
    }

    @Test
    static func PatternReturnsWildcardParenthesized() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->(_)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns([nil])))
    }

    @Test
    static func PatternReturnsDoubleParenthesized() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)->(Double)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.returns(["Double"])))
    }

    @Test
    static func PatternFullSignature1() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)-(_,Int)->_")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.function([nil, "Int"], [nil])))
    }

    @Test
    static func PatternFullSignature2() throws
    {
        let link:UCF.Selector = try Self.roundtrip("Sloth/update(_:)-(_,Int)->(_,Int)")

        #expect(link.path.components == ["Sloth", "update(_:)"])
        #expect(link.path.hasTrailingParentheses)
        #expect(link.suffix == .signature(.function([nil, "Int"], [nil, "Int"])))
    }

    @Test
    static func PatternComplexSignature1() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(Int?)->Int?")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["Int?"], ["Int?"])))
    }
    @Test
    static func PatternComplexSignature2() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-((Int?))->(Int?)")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["Int?"], ["Int?"])))
    }
    @Test
    static func PatternComplexSignature3() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-([(Int?)].Type)->[Int?].Type")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["[Int?].Type"], ["[Int?].Type"])))
    }
    @Test
    static func PatternComplexSignature4() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-([[T]:Set<T>],[T])->[[Int?]??:`A B`]")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(
            ["[[T]:Set<T>]", "[T]"],
            ["[[Int?]??:`A B`]"])))
    }
    @Test
    static func PatternComplexSignature5() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(Foo<T,U>.Out.Type)")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["Foo<T,U>.Out.Type"])))
    }
    @Test
    static func PatternComplexSignature6() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(Foo<[T].Type,U<T>?>.Out.Type)")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["Foo<[T].Type,U<T>?>.Out.Type"])))
    }
    @Test
    static func PatternComplexSignature7() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(Foo<([(T)]).Type,(U<T>?)>.Out.Type)")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["Foo<[T].Type,U<T>?>.Out.Type"])))
    }
    @Test
    static func PatternComplexSignature8() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(((Foo<T>)))->((()))")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function(["Foo<T>"], [])))
    }
    @Test
    static func PatternComplexSignature9() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)->(((Foo<T>)))->((()))")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.returns(["(Foo<T>)->()"])))
    }
    @Test
    static func PatternComplexSignature10() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)->(((Foo<T>)))->((Int))")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.returns(["(Foo<T>)->Int"])))
    }
    @Test
    static func PatternComplexSignature11() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(((_)))->((_),_)")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function([nil], [nil, nil])))
    }
    @Test
    static func PatternComplexSignature12() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(((_)))->((),())")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function([nil], ["()", "()"])))
    }
    @Test
    static func PatternComplexSignature13() throws
    {
        let link:UCF.Selector = try Self.roundtrip("f(_:)-(((_)))->(((((())),((())))))")

        #expect(link.path.components == ["f(_:)"])
        #expect(link.suffix == .signature(.function([nil], ["()", "()"])))
    }
}
