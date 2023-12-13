import MongoDB
import MongoTesting
import Symbols
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import Unidoc
import UnidocDB
import UnidocQueries
import UnidocRecords

struct SymbolQueries:UnidocDatabaseTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup,
        pool:Mongo.SessionPool,
        unidoc:UnidocDatabase) async throws
    {
        let workspace:Workspace = try await .create(at: ".testing")
        let toolchain:Toolchain = try await .detect()

        let example:SymbolGraphArchive = try await toolchain.generateDocs(
            for: try await .local(package: "swift-malibu",
                from: "TestPackages",
                in: workspace,
                clean: true),
            pretty: true)

        example.roundtrip(for: tests, in: workspace.path)

        let swift:SymbolGraphArchive
        do
        {
            //  Use the cached binary if available.
            swift = try .load(package: .swift, at: toolchain.version, in: workspace.path)
        }
        catch
        {
            swift = try await toolchain.generateDocs(
            for: try await .swift(in: workspace, clean: true))
        }

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await unidoc.publish(docs: consume swift, with: session).0 ==? .init(
            edition: .init(package: 0, version: 0),
            updated: false))

        tests.expect(try await unidoc.publish(docs: consume example, with: session).0 ==? .init(
            edition: .init(package: 1, version: -1),
            updated: false))

        try await Self.run(decls: tests / "Decls",
            session: session,
            unidoc: unidoc)
    }

    private static
    func run(decls tests:TestGroup?, session:Mongo.Session, unidoc:UnidocDatabase) async throws
    {
        guard
        let tests:TestGroup
        else
        {
            return
        }

        /// We should be able to resolve the ``Dictionary.Keys`` type without hashes.
        if  let tests:TestGroup = tests / "Dictionary" / "Keys"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "swift", ["swift", "dictionary", "keys"])
            await tests.do
            {

                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let vertex:Volume.Vertex.Decl = tests.expect(
                        value: output.principal?.vertex?.decl)
                {
                    tests.expect(vertex.stem.last ==? "Keys")
                }
            }
        }

        /// We should be able to get multiple results back for an ambiguous query.
        if  let tests:TestGroup = tests / "Int" / "init"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "swift", ["swift", "int.init(_:)"])
            await tests.do
            {

                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let principal:Volume.PrincipalOutput = tests.expect(
                        value: output.principal),
                    tests.expect(principal.matches.count >? 1),
                    tests.expect(nil: principal.vertex)
                {
                }
            }
        }

        /// We should be able to disambiguate the previous query with an FNV-1 hash.
        if  let tests:TestGroup = tests / "Int" / "init" / "hashed"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "swift", ["swift", "int.init(_:)"],
                hash: .init("8VBWO"))
            await tests.do
            {

                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let principal:Volume.PrincipalOutput = tests.expect(
                        value: output.principal),
                    let _:Volume.Vertex = tests.expect(value: principal.vertex)
                {
                }
            }
        }

        /// We should be able to use a mangled decl identifier to obtain a redirect.
        if  let tests:TestGroup = tests / "Int" / "init" / "overload"
        {
            let query:Volume.RedirectQuery<Symbol.Decl> = .init(
                volume: .init(package: "swift", version: nil),
                lookup: .init(.s, ascii: "Si10bitPatternSiSO_tcfc"))

            await tests.do
            {
                if  let output:Volume.RedirectOutput = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let vertex:Volume.Vertex.Decl = tests.expect(
                        value: output.matches.first?.decl)
                {
                    tests.expect(vertex.stem.last ==? "init(bitPattern:)")
                }
            }
        }

        if  let tests:TestGroup = tests / "Parentheses"
        {
            for (name, query):(String, Volume.LookupQuery<Volume.LookupAdjacent, Any>) in
            [
                (
                    "None",
                    .init("swift", ["swift", "bidirectionalcollection.reversed"])
                ),
                (
                    "Empty",
                    .init("swift", ["swift", "bidirectionalcollection.reversed()"])
                ),
            ]
            {
                guard
                    let tests:TestGroup = tests / name,
                    let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = tests.expect(
                        value: query)
                else
                {
                    continue
                }
                await tests.do
                {
                    if  let output:Volume.LookupOutput<Any> = tests.expect(
                            value: try await unidoc.execute(query: query, with: session)),
                        let _:Volume.Vertex = tests.expect(value: output.principal?.vertex)
                    {
                    }
                }
            }
        }

        if  let tests:TestGroup = tests / "BarbieCore"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "swift-malibu", ["barbiecore"])
            await tests.do
            {
                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let vertex:Volume.Vertex.Culture = tests.expect(
                        value: output.principal?.vertex?.culture),
                    let tree:Volume.TypeTree = tests.expect(
                        value: output.principal?.tree)
                {
                    tests.expect(vertex.id ==? tree.id)
                    tests.expect(tree.rows ..?
                        [
                            .init(stem: "BarbieCore Getting-Started", text: "Getting started"),
                            .init(stem: "BarbieCore Barbie", from: .culture),
                            .init(stem: "BarbieCore Barbie ID", from: .culture),
                            .init(stem: "BarbieCore Barbie PlasticKeychain", from: .culture),
                        ])
                }
            }
        }

        /// The ``Barbie.Dreamhouse`` type has a doccomment with many cross-module
        /// and cross-package references. We should be able to resolve all of them.
        /// The type itself lives in ``BarbieHousing``, but it is namespaced to
        /// ``BarbieCore.Barbie``, and its codelinks should resolve relative to that
        /// namespace.
        if  let tests:TestGroup = tests / "Barbie" / "Dreamhouse"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "swift-malibu", ["barbiecore", "barbie", "dreamhouse"])
            await tests.do
            {
                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let vertex:Volume.Vertex = tests.expect(
                        value: output.principal?.vertex),
                    let tree:Volume.TypeTree = tests.expect(
                        value: output.principal?.tree),
                    let overview:Volume.Passage = tests.expect(
                        value: vertex.overview),
                    tests.expect(overview.outlines.count ==? 5)
                {
                    tests.expect(tree.rows ..?
                        [
                            .init(stem: "BarbieCore Barbie", from: .package),
                            .init(stem: "BarbieCore Barbie Dreamhouse", from: .culture),
                            .init(stem: "BarbieCore Barbie Dreamhouse Keys", from: .culture),
                            .init(stem: "BarbieCore Barbie PlasticKeychain", from: .package),
                            .init(stem: "Swift Array", from: .foreign),
                        ])

                    let secondaries:Set<Unidoc.Scalar> = .init(output.vertices.lazy.map(\.id))

                    for outline:Volume.Outline in overview.outlines
                    {
                        let scalars:[Unidoc.Scalar]?
                        switch outline
                        {
                        case    .path("Int", let path),
                                .path("ID", let path),
                                .path("Barbie", let path):
                            tests.expect(path.count ==? 1)
                            scalars = path

                        case    .path("Barbie ID", let path):
                            tests.expect(path.count ==? 2)
                            scalars = path

                        case    .path("BarbieCore Barbie ID", let path):
                            tests.expect(path.count ==? 2)
                            scalars = path

                        case _:
                            scalars = nil
                        }

                        guard let scalars:[Unidoc.Scalar] = tests.expect(value: scalars)
                        else
                        {
                            continue
                        }

                        for scalar:Unidoc.Scalar in scalars
                        {
                            tests.expect(true: secondaries.contains(scalar))
                        }
                    }
                }
            }
        }
        /// The symbol graph linker should have mangled the space in `Getting Started.md`
        /// into a hyphen.
        if  let tests:TestGroup = tests / "Barbie" / "GettingStarted"
        {
            let query:Volume.LookupQuery<Volume.LookupAdjacent, Any> = .init(
                "swift-malibu", ["barbiecore", "getting-started"])
            await tests.do
            {

                if  let output:Volume.LookupOutput<Any> = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let _:Volume.Vertex = tests.expect(
                        value: output.principal?.vertex)
                {
                }
            }
        }

        if  let tests:TestGroup = tests / "SeeAlso"
        {
            if  let test:TestCase = .init(tests / "GeneratedFromTopics",
                    package: "swift-malibu",
                    path: ["barbiecore", "barbie", "plastickeychain.startindex"],
                    expecting:
                    [
                        "endIndex",
                        "startIndex",
                    ],
                    except:
                    [
                        "subscript(_:)",
                    ],
                    filter: .topics)
            {
                await test.run(on: unidoc, with: session)
            }
        }

        /// The ``BarbieHousing`` module vends an extension on ``Array`` that
        /// conforms it to the ``DollhouseSecurity.DollhouseKeychain`` protocol.
        /// The database should return this conformance as an extension on ``Array``,
        /// and it should not duplicate the features or conformances that already
        /// exist on ``Array``.
        ///
        /// The database should also perform the same de-duplication for
        /// conformances within the same package.
        if  let tests:TestGroup = tests / "Deduplication"
        {
            if  let test:TestCase = .init(tests / "Array",
                    package: "swift",
                    path: ["swift", "array"],
                    expecting:
                    [
                        "Sequence",
                        "Collection",
                        "BidirectionalCollection",
                        "RandomAccessCollection",
                        "suffix(from:)",
                    ],
                    except:
                    [
                        "DollhouseKeychain",
                        "find(for:)",
                    ],
                    filter: .extensions)
            {
                await test.run(on: unidoc, with: session)
            }
            if  let test:TestCase = .init(tests / "PlasticKeychain",
                    package: "swift-malibu",
                    path: ["barbiecore", "barbie", "plastickeychain"],
                    expecting:
                    [
                        "Sequence",
                        "Collection",
                        "BidirectionalCollection",
                        "RandomAccessCollection",
                        "suffix(from:)",

                        "DollhouseKeychain",
                        "find(for:)",
                    ],
                    filter: .extensions)
            {
                await test.run(on: unidoc, with: session)
            }
        }

        /// These tests are destructive, so we run them last.
        guard
        let tests:TestGroup = tests / "Realms"
        else
        {
            return
        }

        let setup:TestGroup = tests ! "Setup"
        let realm:Unidoc.Realm? = await setup.do
        {
            let (realm, new):(Unidoc.RealmMetadata, Bool) = try await unidoc.index(
                realm: "barbieland",
                with: session)

            setup.expect(true: new)
            setup.expect(realm.id ==? 0)
            setup.expect(realm.symbol ==? "barbieland")

            return realm.id
        }
        _ = consume setup

        guard
        let realm:Unidoc.Realm
        else
        {
            return
        }

        if  let test:TestCase = .init(tests / "RealmContainingBoth",
                package: "swift",
                path: ["swift", "array"],
                expecting:
                [
                    "Sequence",
                    "Collection",
                    "BidirectionalCollection",
                    "RandomAccessCollection",
                    "suffix(from:)",

                    "DollhouseKeychain",
                    "find(for:)",
                ],
                filter: .extensions)
        {
            try await unidoc.align(package: 0, realm: realm, with: session)
            try await unidoc.align(package: 1, realm: realm, with: session)

            await test.run(on: unidoc, with: session)
        }
        if  let test:TestCase = .init(tests / "RealmContainingStandardLibrary",
                package: "swift",
                path: ["swift", "array"],
                expecting:
                [
                    "Sequence",
                    "Collection",
                    "BidirectionalCollection",
                    "RandomAccessCollection",
                    "suffix(from:)",
                ],
                except:
                [
                    "DollhouseKeychain",
                    "find(for:)",
                ],
                filter: .extensions)
        {
            try await unidoc.align(package: 0, realm: realm, with: session)
            try await unidoc.align(package: 1, realm: nil, with: session)

            await test.run(on: unidoc, with: session)
        }
        if  let test:TestCase = .init(tests / "RealmContainingPackage",
                package: "swift",
                path: ["swift", "array"],
                expecting:
                [
                    "Sequence",
                    "Collection",
                    "BidirectionalCollection",
                    "RandomAccessCollection",
                    "suffix(from:)",
                ],
                except:
                [
                    "DollhouseKeychain",
                    "find(for:)",
                ],
                filter: .extensions)
        {
            try await unidoc.align(package: 0, realm: nil, with: session)
            try await unidoc.align(package: 1, realm: realm, with: session)

            await test.run(on: unidoc, with: session)
        }
        if  let test:TestCase = .init(tests / "RealmContainingNeither",
                package: "swift",
                path: ["swift", "array"],
                expecting:
                [
                    "Sequence",
                    "Collection",
                    "BidirectionalCollection",
                    "RandomAccessCollection",
                    "suffix(from:)",
                ],
                except:
                [
                    "DollhouseKeychain",
                    "find(for:)",
                ],
                filter: .extensions)
        {
            try await unidoc.align(package: 0, realm: nil, with: session)
            try await unidoc.align(package: 1, realm: nil, with: session)

            await test.run(on: unidoc, with: session)
        }
    }
}
