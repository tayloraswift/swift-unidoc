import UCF
import FNV1
import Testing_

extension Main
{
    enum ParseCodelink
    {
    }
}
extension Main.ParseCodelink:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "UCF.Selector" / "Path"
        {
            if  let tests:TestGroup = tests / "DotDot",
                let link:UCF.Selector = tests.roundtrip("Unicode.Scalar.value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["Unicode", "Scalar", "value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "SlashDot",
                let link:UCF.Selector = tests.roundtrip("Unicode/Scalar.value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["Scalar", "value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "DotSlash",
                let link:UCF.Selector = tests.roundtrip("Unicode.Scalar/value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "SlashSlash",
                let link:UCF.Selector = tests.roundtrip("Unicode/Scalar/value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "SingleCharacter",
                let link:UCF.Selector = tests.roundtrip("x")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["x"])
                tests.expect(link.path.visible ..? ["x"])
                tests.expect(nil: link.suffix)
            }

            if  let tests:TestGroup = tests / "Real" / "1",
                let link:UCF.Selector = tests.roundtrip("Real...(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "..(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "..(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "2",
                let link:UCF.Selector = tests.roundtrip("Real/..(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "..(_:_:)"])
                tests.expect(link.path.visible ..? ["..(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "3",
                let link:UCF.Selector = tests.roundtrip("Real....(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "...(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "...(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "4",
                let link:UCF.Selector = tests.roundtrip("Real/...(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "...(_:_:)"])
                tests.expect(link.path.visible ..? ["...(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "5",
                let link:UCF.Selector = tests.roundtrip("Real./(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "/(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "6",
                let link:UCF.Selector = tests.roundtrip("Real//(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "/(_:_:)"])
                tests.expect(link.path.visible ..? ["/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "7",
                let link:UCF.Selector = tests.roundtrip("Real../.(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "./.(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "./.(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "8",
                let link:UCF.Selector = tests.roundtrip("Real/./.(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "./.(_:_:)"])
                tests.expect(link.path.visible ..? ["./.(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "EmptyTrailingParentheses",
                let link:UCF.Selector = tests.roundtrip("Real.init()")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "init"])
                tests.expect(link.path.visible ..? ["Real", "init"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "EmptyTrailingComponent",
                let link:UCF.Selector = tests.roundtrip("Real.init/")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "init"])
                tests.expect(link.path.visible ..? ["Real", "init"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "DivisionOperator",
                let link:UCF.Selector = tests.roundtrip("/(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["/(_:_:)"])
                tests.expect(link.path.visible ..? ["/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "CustomOperator",
                let link:UCF.Selector = tests.roundtrip("/-/(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["/-/(_:_:)"])
                tests.expect(link.path.visible ..? ["/-/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "ClosedRangeOperator",
                let link:UCF.Selector = tests.roundtrip("...(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["...(_:_:)"])
                tests.expect(link.path.visible ..? ["...(_:_:)"])
                tests.expect(nil: link.suffix)
            }
        }
        if  let tests:TestGroup = tests / "UCF.Selector" / "Disambiguator"
        {
            if  let tests:TestGroup = tests / "Fake" / "Enum",
                let link:UCF.Selector = tests.roundtrip("Fake [enum]")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Fake"])
                tests.expect(link.suffix ==? .filter(.enum))
            }
            if  let tests:TestGroup = tests / "Fake" / "UncannyHash",
                let link:UCF.Selector = tests.roundtrip("Fake [ENUM]")
            {
                let hash:FNV24 = .init("ENUM", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Fake"])
                tests.expect(link.suffix ==? .hash(hash))
            }
            if  let tests:TestGroup = tests / "Fake" / "ClassVar",
                let link:UCF.Selector = tests.roundtrip("Fake.max [class var]")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Fake", "max"])
                tests.expect(link.suffix ==? .filter(.class_var))
            }
        }
        if  let tests:TestGroup = tests / "UCF.Selector" / "DocC"
        {
            if  let tests:TestGroup = tests / "Slashes",
                let link:UCF.Selector = tests.roundtrip("Sloth/Color")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Filter",
                let link:UCF.Selector = tests.roundtrip("Sloth/Color-swift.enum")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(link.suffix ==? .filter(.enum))
            }
            if  let tests:TestGroup = tests / "FilterInterior",
                let link:UCF.Selector = tests.roundtrip("Sloth-swift.struct/Color")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "FilterLegacy",
                let link:UCF.Selector = tests.roundtrip("Sloth/Color-swift.class")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(link.suffix ==? .legacy(.class, nil))
            }
            if  let tests:TestGroup = tests / "FilterAndHash",
                let link:UCF.Selector = tests.roundtrip("Sloth/Color-swift.struct-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(link.suffix ==? .legacy(.struct, hash))
            }
            if  let tests:TestGroup = tests / "Hash",
                let link:UCF.Selector = tests.roundtrip("Sloth/update(_:)-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "update(_:)"])
                tests.expect(link.path.visible ..? ["update(_:)"])
                tests.expect(link.suffix ==? .hash(hash))
            }
            if  let tests:TestGroup = tests / "Hash" / "Minus",
                let link:UCF.Selector = tests.roundtrip("Sloth/-(_:)-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "-(_:)"])
                tests.expect(link.path.visible ..? ["-(_:)"])
                tests.expect(link.suffix ==? .hash(hash))
            }
            if  let tests:TestGroup = tests / "Hash" / "Slinging" / "Slasher",
                let link:UCF.Selector = tests.roundtrip("Sloth//(_:)-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "/(_:)"])
                tests.expect(link.path.visible ..? ["/(_:)"])
                tests.expect(link.suffix ==? .hash(hash))
            }
        }
        if  let tests:TestGroup = tests / "UCF.Selector" / "Namespacing"
        {
            if  let tests:TestGroup = tests / "Isolated",
                let link:UCF.Selector = tests.roundtrip("/Swift")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift"])
                tests.expect(link.path.visible ..? ["Swift"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Hidden",
                let link:UCF.Selector = tests.roundtrip("/Swift/Int")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift", "Int"])
                tests.expect(link.path.visible ..? ["Int"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Visible",
                let link:UCF.Selector = tests.roundtrip("/Swift.Int")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift", "Int"])
                tests.expect(link.path.visible ..? ["Swift", "Int"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "EmptyTrailingComponent",
                let link:UCF.Selector = tests.roundtrip("/Swift.Int/")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift", "Int"])
                tests.expect(link.path.visible ..? ["Swift", "Int"])
                tests.expect(nil: link.suffix)
            }
        }
    }
}
