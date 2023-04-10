import Codelinks
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "identifiers"
        {
            if  let tests:TestGroup = tests / "underscore"
            {
                tests.expect(value: Codelink.Identifier.init("_"))
            }
            if  let tests:TestGroup = tests / "letter"
            {
                tests.expect(value: Codelink.Identifier.init("x"))
            }
            if  let tests:TestGroup = tests / "backticks",
                let identifier:Codelink.Identifier = tests.expect(value: .init("`subscript`"))
            {
                tests.expect(identifier.description ==? "`subscript`")
                tests.expect(identifier.unencased ==? "subscript")
                tests.expect(true: identifier.encased)
            }
            if  let tests:TestGroup = tests / "number-suffix"
            {
                tests.expect(value: Codelink.Identifier.init("x0"))
            }
            if  let tests:TestGroup = tests / "number-prefix"
            {
                tests.expect(nil: Codelink.Identifier.init("0x"))
            }
            if  let tests:TestGroup = tests / "spaces"
            {
                tests.expect(nil: Codelink.Identifier.init("x x"))
            }
        }
        if  let tests:TestGroup = tests / "operators"
        {
            if  let tests:TestGroup = tests / "underscore"
            {
                tests.expect(nil: Codelink.Operator.init("_"))
            }
            if  let tests:TestGroup = tests / "letter"
            {
                tests.expect(nil: Codelink.Operator.init("x"))
            }
            if  let tests:TestGroup = tests / "plus"
            {
                tests.expect(value: Codelink.Operator.init("+"))
            }
            if  let tests:TestGroup = tests / "slash"
            {
                tests.expect(value: Codelink.Operator.init("/"))
            }
            if  let tests:TestGroup = tests / "plusplus"
            {
                tests.expect(value: Codelink.Operator.init("++"))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(value: Codelink.Operator.init("..."))
            }
            if  let tests:TestGroup = tests / "dots-invalid"
            {
                tests.expect(nil: Codelink.Operator.init("+.."))
            }
            if  let tests:TestGroup = tests / "spaces"
            {
                tests.expect(nil: Codelink.Identifier.init("+ +"))
            }
        }
        if  let tests:TestGroup = tests / "operators" / "reserved"
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
                    tests.expect(nil: Codelink.Operator.init(pattern))
                }
            }
        }
        if  let tests:TestGroup = tests / "codelinks"
        {
            if  let tests:TestGroup = tests / "component-single",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["Sloth"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-multiple",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth.Color.description"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "description"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-parentheses",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth.Color.foo()"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "foo"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-arguments",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth.Color.foo(bar:baz:)"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "foo(bar:baz:)"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-operator",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth.Color.==(_:_:)"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "==(_:_:)"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "component-operator-only",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "==(_:_:)"))
            {
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["==(_:_:)"])
            }
            if  let tests:TestGroup = tests / "component-dots",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth.Color....(_:_:)"))
            {
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["Sloth", "Color", "...(_:_:)"])
            }
            if  let tests:TestGroup = tests / "component-dots-only",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "...(_:_:)"))
            {
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["...(_:_:)"])
            }
        }
        if  let tests:TestGroup = tests / "codelinks" / "filters"
        {
            if  let tests:TestGroup = tests / "case",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "case `subscript`"))
            {
                tests.expect(codelink.filter ==? .case)
                tests.expect(nil: codelink.scope)
                tests.expect(nil: codelink.path.collation)
                tests.expect(codelink.path.components ..? ["subscript"])
                tests.expect(nil: codelink.hash)
            }

            if  let tests:TestGroup = tests / "init",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth Color.init")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .initializer)
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "init"])
            }

            if  let tests:TestGroup = tests / "subscript",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth Color.subscript(_:)")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .subscript(.instance))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }
            if  let tests:TestGroup = tests / "class-subscript",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "class Sloth Color.subscript(_:)")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .subscript(.class))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }
            if  let tests:TestGroup = tests / "static-subscript",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "static Sloth Color.subscript(_:)")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .subscript(.static))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }

            if  let tests:TestGroup = tests / "func",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "func Sloth Color.`subscript`(_:)")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .func(.default))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }
            if  let tests:TestGroup = tests / "class-func",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "class func Sloth Color.`subscript`(_:)")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .func(.class))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }
            if  let tests:TestGroup = tests / "static-func",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "static func Sloth Color.`subscript`(_:)")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .func(.static))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript(_:)"])
            }

            if  let tests:TestGroup = tests / "var",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "var Sloth Color.`subscript`")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .var(.default))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript"])
            }
            if  let tests:TestGroup = tests / "class-var",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "class var Sloth Color.`subscript`")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .var(.class))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript"])
            }
            if  let tests:TestGroup = tests / "static-var",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "static var Sloth Color.`subscript`")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .var(.static))
                tests.expect(scope.components ..? ["Sloth"])
                tests.expect(codelink.path.components ..? ["Color", "subscript"])
            }

            if  let tests:TestGroup = tests / "actor",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "actor Actor"))
            {
                tests.expect(codelink.filter ==? .actor)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.components ..? ["Actor"])
            }

            if  let tests:TestGroup = tests / "scopes",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "class actor Class")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(codelink.filter ==? .class)
                tests.expect(scope.components ..? ["actor"])
                tests.expect(codelink.path.components ..? ["Class"])
            }
        }
        if  let tests:TestGroup = tests / "codelinks" / "scopes"
        {
            if  let tests:TestGroup = tests / "encasing",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "`actor` Class")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(nil: codelink.filter)
                tests.expect(scope.components ..? ["actor"])
                tests.expect(codelink.path.components ..? ["Class"])
            }
            if  let tests:TestGroup = tests / "qualified",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Foo.Bar.Baz Sloth.Color")),
                let scope:Codelink.Scope = tests.expect(value: codelink.scope)
            {
                tests.expect(nil: codelink.filter)
                tests.expect(scope.components ..? ["Foo", "Bar", "Baz"])
                tests.expect(codelink.path.components ..? ["Sloth", "Color"])
            }
        }
        if  let tests:TestGroup = tests / "codelinks" / "hashes",
            let codelink:Codelink = tests.expect(value: .init(
                parsing: "Sloth.update(_:) [4ko57]"))
        {
            tests.expect(nil: codelink.filter)
            tests.expect(nil: codelink.scope)
            tests.expect(nil: codelink.path.collation)
            tests.expect(codelink.path.components ..? ["Sloth", "update(_:)"])
            tests.expect(codelink.hash?.value ==? .init("4ko57", radix: 36))
        }
        if  let tests:TestGroup = tests / "codelinks" / "legacy-docc"
        {
            if  let tests:TestGroup = tests / "slashes",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth/Color"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.collation ==? .legacy)
                tests.expect(codelink.path.components ..? ["Sloth", "Color"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "filter",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth/Color-swift.enum"))
            {
                tests.expect(codelink.filter ==? .enum)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.collation ==? .legacy)
                tests.expect(codelink.path.components ..? ["Sloth", "Color"])
                tests.expect(nil: codelink.hash)
            }
            if  let tests:TestGroup = tests / "hash",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth/update(_:)-4ko57"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.collation ==? .legacy)
                tests.expect(codelink.path.components ..? ["Sloth", "update(_:)"])
                tests.expect(codelink.hash?.value ==? .init("4ko57", radix: 36))
            }
            if  let tests:TestGroup = tests / "hash" / "minus",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth/-(_:)-4ko57"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.collation ==? .legacy)
                tests.expect(codelink.path.components ..? ["Sloth", "-(_:)"])
                tests.expect(codelink.hash?.value ==? .init("4ko57", radix: 36))
            }
            if  let tests:TestGroup = tests / "hash" / "slinging" / "slasher",
                let codelink:Codelink = tests.expect(value: .init(
                    parsing: "Sloth//(_:)-4ko57"))
            {
                tests.expect(nil: codelink.filter)
                tests.expect(nil: codelink.scope)
                tests.expect(codelink.path.collation ==? .legacy)
                tests.expect(codelink.path.components ..? ["Sloth", "/(_:)"])
                tests.expect(codelink.hash?.value ==? .init("4ko57", radix: 36))
            }
        }
    }
}
