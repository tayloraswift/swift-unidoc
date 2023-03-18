import JSON
import SymbolNamespaces
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "phyla"
        {
            let phyla:[SymbolPhylum: [SymbolDescription]] = tests.do
            {
                let filepath:FilePath = "TestModules/Symbolgraphs/Phyla.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                let namespace:SymbolNamespace = try .init(json: json)

                tests.expect(namespace.metadata.version ==? .v(0, 6, 0))

                return .init(
                    grouping: namespace.symbols.lazy.filter { $0.visibility >= .public },
                    by: \.phylum)
            } ?? [:]

            for (phylum, path):(SymbolPhylum, SymbolPath) in
            [
                (.actor,            "Actor"),
                (.class,            "Class"),
                (.enum,             "Enum"),
                (.case,             "Enum" / "case"),
                (.protocol,         "Protocol"),
                (.associatedtype,   "Protocol" / "AssociatedType"),
                (.struct,           "Struct"),
                (.typealias,        "Typealias"),
                (.var,              "Var"),
            ]
            {
                if  let tests:TestGroup = tests / path.last.lowercased(),
                    let symbols:[SymbolDescription] = tests.expect(value: phyla[phylum]),
                    tests.expect(symbols.count ==? 1)
                {
                    tests.expect(symbols[0].path ==? path)
                }
            }

            if  let tests:TestGroup = tests / "deinit"
            {
                tests.expect(nil: phyla[.deinitializer])
            }

            if  let tests:TestGroup = tests / "func" / "global",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.func]),
                tests.expect(symbols.count ==? 1)
            {
                tests.expect(symbols[0].path ==? "Func")
            }
            if  let tests:TestGroup = tests / "func" / "instance",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.instanceMethod]),
                tests.expect(symbols.count ==? 1)
            {
                tests.expect(symbols[0].path ==? "Struct" / "instanceMethod")
            }
            if  let tests:TestGroup = tests / "func" / "static",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.typeMethod]),
                tests.expect(symbols.count ==? 1)
            {
                tests.expect(symbols[0].path ==? "Struct" / "typeMethod")
            }

            if  let tests:TestGroup = tests / "init",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.initializer]),
                tests.expect(symbols.count ==? 2)
            {
                tests.expect(symbols.map(\.path) **?
                [
                    "Class" / "init",
                    "Actor" / "init",
                ])
            }

            if  let tests:TestGroup = tests / "operator" / "global",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.operator]),
                tests.expect(symbols.count ==? 3)
            {
                tests.expect(symbols.map(\.path) **?
                [
                    "?/(_:)",
                    "<-(_:_:)",
                    "/?(_:)",
                ])
            }
            if  let tests:TestGroup = tests / "operator" / "static",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.typeOperator]),
                tests.expect(symbols.count ==? 4)
            {
                tests.expect(symbols.map(\.path) **?
                [
                    //  Why is this here???
                    "Enum" / "!=(_:_:)",

                    "Struct" / "?/(_:)",
                    "Struct" / "<-(_:_:)",
                    "Struct" / "/?(_:)",
                ])
            }

            if  let tests:TestGroup = tests / "subscript" / "instance",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.instanceSubscript]),
                tests.expect(symbols.count ==? 1)
            {
                tests.expect(symbols[0].path ==? "Struct" / "subscript")
            }
            if  let tests:TestGroup = tests / "subscript" / "static",
                let symbols:[SymbolDescription] = tests.expect(value: phyla[.typeSubscript]),
                tests.expect(symbols.count ==? 1)
            {
                tests.expect(symbols[0].path ==? "Struct" / "subscript(_:)")
            }
        }
        if  let tests:TestGroup = tests / "phyla" / "extension"
        {
            let phyla:[SymbolPhylum: [SymbolDescription]] = tests.do
            {
                let filepath:FilePath = "TestModules/Symbolgraphs/Phyla@Swift.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                let namespace:SymbolNamespace = try .init(json: json)

                tests.expect(namespace.metadata.version ==? .v(0, 6, 0))

                return .init(
                    grouping: namespace.symbols.lazy.filter { $0.visibility >= .public },
                    by: \.phylum)
            } ?? [:]

            for (phylum, path):(SymbolPhylum, SymbolPath) in
            [
                (.extension,    "Int"),
                (.typealias,    "Int" / "AssociatedType"),
            ]
            {
                if  let tests:TestGroup = tests / path.last.lowercased(),
                    let symbols:[SymbolDescription] = tests.expect(value: phyla[phylum]),
                    tests.expect(symbols.count ==? 1)
                {
                    tests.expect(symbols[0].path ==? path)
                }
            }
        }
        if  let tests:TestGroup = tests / "protocols"
        {
            tests.do
            {
                let filepath:FilePath = "TestModules/Symbolgraphs/Protocols.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                let namespace:SymbolNamespace = try .init(json: json)
                tests.expect(namespace.metadata.version ==? .v(0, 6, 0))
            }
        }
        #if !DEBUG
        if  let tests:TestGroup = tests / "stdlib"
        {
            tests.do
            {
                let filepath:FilePath = "TestModules/Symbolgraphs/Swift.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                let namespace:SymbolNamespace = try .init(json: json)
                tests.expect(namespace.metadata.version ==? .v(0, 6, 0))
            }
        }
        #endif
    }
}
