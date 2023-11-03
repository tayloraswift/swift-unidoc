import Codelinks
import FNV1
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
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
        }


        if  let tests:TestGroup = tests / "Identifiers"
        {
            if  let tests:TestGroup = tests / "underscore"
            {
                tests.expect(value: CodelinkV3.Identifier.init("_"))
            }
            if  let tests:TestGroup = tests / "letter"
            {
                tests.expect(value: CodelinkV3.Identifier.init("x"))
            }
            if  let tests:TestGroup = tests / "backticks",
                let identifier:CodelinkV3.Identifier = tests.expect(value: .init("`subscript`"))
            {
                tests.expect(identifier.description ==? "`subscript`")
                tests.expect(identifier.unencased ==? "subscript")
                tests.expect(true: identifier.encased)
            }
            if  let tests:TestGroup = tests / "number-suffix"
            {
                tests.expect(value: CodelinkV3.Identifier.init("x0"))
            }
            if  let tests:TestGroup = tests / "number-prefix"
            {
                tests.expect(nil: CodelinkV3.Identifier.init("0x"))
            }
            if  let tests:TestGroup = tests / "spaces"
            {
                tests.expect(nil: CodelinkV3.Identifier.init("x x"))
            }
        }
        if  let tests:TestGroup = tests / "Operators"
        {
            if  let tests:TestGroup = tests / "underscore"
            {
                tests.expect(nil: CodelinkV3.Operator.init("_"))
            }
            if  let tests:TestGroup = tests / "letter"
            {
                tests.expect(nil: CodelinkV3.Operator.init("x"))
            }
            if  let tests:TestGroup = tests / "plus"
            {
                tests.expect(value: CodelinkV3.Operator.init("+"))
            }
            if  let tests:TestGroup = tests / "slash"
            {
                tests.expect(value: CodelinkV3.Operator.init("/"))
            }
            if  let tests:TestGroup = tests / "plusplus"
            {
                tests.expect(value: CodelinkV3.Operator.init("++"))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(value: CodelinkV3.Operator.init("..."))
            }
            if  let tests:TestGroup = tests / "dots-invalid"
            {
                tests.expect(nil: CodelinkV3.Operator.init("+.."))
            }
            if  let tests:TestGroup = tests / "spaces"
            {
                tests.expect(nil: CodelinkV3.Identifier.init("+ +"))
            }
        }
        if  let tests:TestGroup = tests / "Operators" / "reserved"
        {
            for (pattern, name):(String, String) in
            [
                (".", "dot"),
                ("=", "equals"),
                ("->", "arrow"),
                ("//", "line-comment"),
                ("/*", "block-comment-start"),
                ("*/", "block-comment-end"),
            ]
            {
                if  let tests:TestGroup = tests / name
                {
                    tests.expect(nil: CodelinkV3.Operator.init(pattern))
                }
            }
        }
        if  let tests:TestGroup = tests / "CodelinkV3"
        {
            if  let tests:TestGroup = tests / "component-single",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth")
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Sloth"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-multiple",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth.Color.description")
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "description"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-parentheses",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth.Color.foo()")
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "foo"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-arguments",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth.Color.foo(bar:baz:)")
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "foo(bar:baz:)"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-operator",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth.Color.==(_:_:)")
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "==(_:_:)"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-operator-only",
                let codelink:CodelinkV3 = tests.roundtrip("==(_:_:)")
            {
                tests.expect(codelink.path.components ..? ["==(_:_:)"])
            }
            if  let tests:TestGroup = tests / "component-dots",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth.Color....(_:_:)")
            {
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "...(_:_:)"])
            }
            if  let tests:TestGroup = tests / "component-dots-only",
                let codelink:CodelinkV3 = tests.roundtrip("...(_:_:)")
            {
                tests.expect(codelink.path.components ..? ["...(_:_:)"])
            }
        }
        if  let tests:TestGroup = tests / "CodelinkV3" / "filters"
        {
            if  let tests:TestGroup = tests / "case",
                let codelink:CodelinkV3 = tests.expect(value: .init("case `subscript`"))
            {
                tests.expect(codelink.filter ==? .case)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["`subscript`"])
                tests.expect(nil: codelink.hash)
            }

            if  let tests:TestGroup = tests / "init",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth Color.init"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(nil: codelink.filter)
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "init"])
            }

            if  let tests:TestGroup = tests / "subscript",
                let codelink:CodelinkV3 = tests.roundtrip("Sloth Color.subscript(_:)"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .subscript(.instance))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }
            if  let tests:TestGroup = tests / "class-subscript",
                let codelink:CodelinkV3 = tests.roundtrip("class Sloth Color.subscript(_:)"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .subscript(.class))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }
            if  let tests:TestGroup = tests / "static-subscript",
                let codelink:CodelinkV3 = tests.roundtrip("static Sloth Color.subscript(_:)"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .subscript(.static))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }

            if  let tests:TestGroup = tests / "func",
                let codelink:CodelinkV3 = tests.roundtrip("func Sloth Color.`subscript`(_:)"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .func(.default))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "`subscript`(_:)"])
            }
            if  let tests:TestGroup = tests / "class-func",
                let codelink:CodelinkV3 = tests.roundtrip("class func Sloth Color.`subscript`(_:)"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .func(.class))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "`subscript`(_:)"])
            }
            if  let tests:TestGroup = tests / "static-func",
                let codelink:CodelinkV3 = tests.roundtrip("static func Sloth Color.`subscript`(_:)"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .func(.static))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "`subscript`(_:)"])
            }

            if  let tests:TestGroup = tests / "var",
                let codelink:CodelinkV3 = tests.roundtrip("var Sloth Color.`subscript`"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .var(.default))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "`subscript`"])
            }
            if  let tests:TestGroup = tests / "class-var",
                let codelink:CodelinkV3 = tests.roundtrip("class var Sloth Color.`subscript`"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .var(.class))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "`subscript`"])
            }
            if  let tests:TestGroup = tests / "static-var",
                let codelink:CodelinkV3 = tests.roundtrip("static var Sloth Color.`subscript`"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .var(.static))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "`subscript`"])
            }

            if  let tests:TestGroup = tests / "actor",
                let codelink:CodelinkV3 = tests.roundtrip("actor Actor")
            {
                tests.expect(codelink.filter ==? .actor)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Actor"])
            }

            if  let tests:TestGroup = tests / "scopes",
                let codelink:CodelinkV3 = tests.roundtrip("class `actor` Class"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .class)
                tests.expect(scope.components ..? ["`actor`"])
                tests.expect(codelink.path.components ..? ["Class"])
            }
        }
        if  let tests:TestGroup = tests / "CodelinkV3" / "scopes"
        {
            if  let tests:TestGroup = tests / "encasing",
                let codelink:CodelinkV3 = tests.roundtrip("`actor` Class"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(nil: codelink.filter)
                tests.expect(scope.components ..? ["`actor`"])
                tests.expect(codelink.path.components ..? ["Class"])
            }
            if  let tests:TestGroup = tests / "qualified",
                let codelink:CodelinkV3 = tests.roundtrip("Foo.Bar.Baz Sloth.Color"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(nil: codelink.filter)
                tests.expect(scope.components ..? ["Foo", "Bar", "Baz"])
                tests.expect(codelink.path.components ..? ["Sloth", "Color"])
            }
            if  let tests:TestGroup = tests / "overencased",
                let codelink:CodelinkV3 = tests.roundtrip("`Foo`.`Bar`.`Baz` `Sloth`.`Color`"),
                let scope:CodelinkV3.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(nil: codelink.filter)
                tests.expect(scope.components ..? ["Foo", "Bar", "Baz"])
                tests.expect(codelink.path.components ..? ["Sloth", "Color"])
            }
        }
        if  let tests:TestGroup = tests / "CodelinkV3" / "hashes",
            let codelink:CodelinkV3 = tests.roundtrip("Sloth.update(_:) [4ko57]")
        {
            tests.expect(nil: codelink.filter)
            tests.expect(nil: codelink.scope)
            tests.expect(codelink.path.components ..? ["Sloth", "update(_:)"])
            tests.expect(codelink.hash?.value ==? .init("4ko57", radix: 36))
        }
    }
}
