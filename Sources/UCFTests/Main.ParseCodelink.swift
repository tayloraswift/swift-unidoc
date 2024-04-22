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
        if  let tests:TestGroup = tests / "Codelink" / "Path"
        {
            if  let tests:TestGroup = tests / "DotDot",
                let link:Codelink = tests.roundtrip("Unicode.Scalar.value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["Unicode", "Scalar", "value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "SlashDot",
                let link:Codelink = tests.roundtrip("Unicode/Scalar.value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["Scalar", "value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "DotSlash",
                let link:Codelink = tests.roundtrip("Unicode.Scalar/value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "SlashSlash",
                let link:Codelink = tests.roundtrip("Unicode/Scalar/value")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Unicode", "Scalar", "value"])
                tests.expect(link.path.visible ..? ["value"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "SingleCharacter",
                let link:Codelink = tests.roundtrip("x")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["x"])
                tests.expect(link.path.visible ..? ["x"])
                tests.expect(nil: link.suffix)
            }

            if  let tests:TestGroup = tests / "Real" / "1",
                let link:Codelink = tests.roundtrip("Real...(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "..(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "..(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "2",
                let link:Codelink = tests.roundtrip("Real/..(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "..(_:_:)"])
                tests.expect(link.path.visible ..? ["..(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "3",
                let link:Codelink = tests.roundtrip("Real....(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "...(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "...(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "4",
                let link:Codelink = tests.roundtrip("Real/...(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "...(_:_:)"])
                tests.expect(link.path.visible ..? ["...(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "5",
                let link:Codelink = tests.roundtrip("Real./(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "/(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "6",
                let link:Codelink = tests.roundtrip("Real//(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "/(_:_:)"])
                tests.expect(link.path.visible ..? ["/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "7",
                let link:Codelink = tests.roundtrip("Real../.(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "./.(_:_:)"])
                tests.expect(link.path.visible ..? ["Real", "./.(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Real" / "8",
                let link:Codelink = tests.roundtrip("Real/./.(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "./.(_:_:)"])
                tests.expect(link.path.visible ..? ["./.(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "EmptyTrailingParentheses",
                let link:Codelink = tests.roundtrip("Real.init()")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "init"])
                tests.expect(link.path.visible ..? ["Real", "init"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "EmptyTrailingComponent",
                let link:Codelink = tests.roundtrip("Real.init/")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Real", "init"])
                tests.expect(link.path.visible ..? ["Real", "init"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "DivisionOperator",
                let link:Codelink = tests.roundtrip("/(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["/(_:_:)"])
                tests.expect(link.path.visible ..? ["/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "CustomOperator",
                let link:Codelink = tests.roundtrip("/-/(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["/-/(_:_:)"])
                tests.expect(link.path.visible ..? ["/-/(_:_:)"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "ClosedRangeOperator",
                let link:Codelink = tests.roundtrip("...(_:_:)")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["...(_:_:)"])
                tests.expect(link.path.visible ..? ["...(_:_:)"])
                tests.expect(nil: link.suffix)
            }
        }
        if  let tests:TestGroup = tests / "Codelink" / "Disambiguator"
        {
            if  let tests:TestGroup = tests / "Fake" / "Enum",
                let link:Codelink = tests.roundtrip("Fake [enum]")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Fake"])
                tests.expect(link.suffix ==? .filter(.enum))
            }
            if  let tests:TestGroup = tests / "Fake" / "UncannyHash",
                let link:Codelink = tests.roundtrip("Fake [ENUM]")
            {
                let hash:FNV24 = .init("ENUM", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Fake"])
                tests.expect(link.suffix ==? .hash(hash))
            }
            if  let tests:TestGroup = tests / "Fake" / "ClassVar",
                let link:Codelink = tests.roundtrip("Fake.max [class var]")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Fake", "max"])
                tests.expect(link.suffix ==? .filter(.class_var))
            }
        }
        if  let tests:TestGroup = tests / "Codelink" / "DocC"
        {
            if  let tests:TestGroup = tests / "Slashes",
                let link:Codelink = tests.roundtrip("Sloth/Color")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Filter",
                let link:Codelink = tests.roundtrip("Sloth/Color-swift.enum")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(link.suffix ==? .filter(.enum))
            }
            if  let tests:TestGroup = tests / "FilterInterior",
                let link:Codelink = tests.roundtrip("Sloth-swift.struct/Color")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "FilterLegacy",
                let link:Codelink = tests.roundtrip("Sloth/Color-swift.class")
            {
                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(link.suffix ==? .legacy(.init(filter: .class)))
            }
            if  let tests:TestGroup = tests / "FilterAndHash",
                let link:Codelink = tests.roundtrip("Sloth/Color-swift.struct-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "Color"])
                tests.expect(link.path.visible ..? ["Color"])
                tests.expect(link.suffix ==? .legacy(.init(filter: .struct, hash: hash)))
            }
            if  let tests:TestGroup = tests / "Hash",
                let link:Codelink = tests.roundtrip("Sloth/update(_:)-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "update(_:)"])
                tests.expect(link.path.visible ..? ["update(_:)"])
                tests.expect(link.suffix ==? .hash(hash))
            }
            if  let tests:TestGroup = tests / "Hash" / "Minus",
                let link:Codelink = tests.roundtrip("Sloth/-(_:)-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "-(_:)"])
                tests.expect(link.path.visible ..? ["-(_:)"])
                tests.expect(link.suffix ==? .hash(hash))
            }
            if  let tests:TestGroup = tests / "Hash" / "Slinging" / "Slasher",
                let link:Codelink = tests.roundtrip("Sloth//(_:)-4ko57")
            {
                let hash:FNV24 = .init("4ko57", radix: 36)!

                tests.expect(link.base ==? .relative)
                tests.expect(link.path.components ..? ["Sloth", "/(_:)"])
                tests.expect(link.path.visible ..? ["/(_:)"])
                tests.expect(link.suffix ==? .hash(hash))
            }
        }
        if  let tests:TestGroup = tests / "Codelink" / "Namespacing"
        {
            if  let tests:TestGroup = tests / "Isolated",
                let link:Codelink = tests.roundtrip("/Swift")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift"])
                tests.expect(link.path.visible ..? ["Swift"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Hidden",
                let link:Codelink = tests.roundtrip("/Swift/Int")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift", "Int"])
                tests.expect(link.path.visible ..? ["Int"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "Visible",
                let link:Codelink = tests.roundtrip("/Swift.Int")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift", "Int"])
                tests.expect(link.path.visible ..? ["Swift", "Int"])
                tests.expect(nil: link.suffix)
            }
            if  let tests:TestGroup = tests / "EmptyTrailingComponent",
                let link:Codelink = tests.roundtrip("/Swift.Int/")
            {
                tests.expect(link.base ==? .qualified)
                tests.expect(link.path.components ..? ["Swift", "Int"])
                tests.expect(link.path.visible ..? ["Swift", "Int"])
                tests.expect(nil: link.suffix)
            }
        }
    }
}
