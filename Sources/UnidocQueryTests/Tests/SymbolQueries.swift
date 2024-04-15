import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import Symbols
import Unidoc
@_spi(testable)
import UnidocDB
import UnidocQueries
import UnidocRecords

struct SymbolQueries:UnidocDatabaseTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup,
        pool:Mongo.SessionPool,
        unidoc:Unidoc.DB) async throws
    {
        let workspace:SSGC.Workspace = try .create(at: ".testing")
        let toolchain:SSGC.Toolchain = try .detect(pretty: true)

        let example:SymbolGraphObject<Void> = try workspace.build(package: try .local(
                package: "swift-malibu",
                from: "TestPackages"),
            with: toolchain)

        example.roundtrip(for: tests, in: workspace.path)

        let swift:SymbolGraphObject<Void>
        do
        {
            //  Use the cached binary if available.
            swift = try .load(swift: toolchain.version, in: workspace.path)
        }
        catch
        {
            swift = try workspace.build(special: .swift, with: toolchain)
        }

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await unidoc.store(linking: swift, with: session).0 ==? .init(
            edition: .init(package: 0, version: 0),
            updated: false))

        tests.expect(try await unidoc.store(linking: example, with: session).0 ==? .init(
            edition: .init(package: 1, version: -1),
            updated: false))

        try await Self.run(decls: tests / "Decls",
            session: session,
            unidoc: unidoc)
    }

    private static
    func run(decls tests:TestGroup?, session:Mongo.Session, unidoc:Unidoc.DB) async throws
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
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift", ["swift", "dictionary", "keys"])
            await tests.do
            {

                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let vertex:Unidoc.DeclVertex = tests.expect(
                        value: output.principal?.vertex?.decl)
                {
                    tests.expect(vertex.stem.last ==? "Keys")
                }
            }
        }

        /// We should be able to get multiple results back for an ambiguous query.
        if  let tests:TestGroup = tests / "Int" / "init"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift", ["swift", "int.init(_:)"])
            await tests.do
            {

                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let principal:Unidoc.PrincipalOutput = tests.expect(
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
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift", ["swift", "int.init(_:)"],
                hash: .init("8VBWO"))
            await tests.do
            {

                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let principal:Unidoc.PrincipalOutput = tests.expect(
                        value: output.principal),
                    let _:Unidoc.AnyVertex = tests.expect(value: principal.vertex)
                {
                }
            }
        }

        /// We should be able to use a mangled decl identifier to obtain a redirect.
        if  let tests:TestGroup = tests / "Int" / "init" / "overload"
        {
            let query:Unidoc.RedirectQuery<Symbol.Decl> = .init(
                volume: .init(package: "swift", version: nil),
                lookup: .init(.s, ascii: "Si10bitPatternSiSO_tcfc"))

            await tests.do
            {
                if  let output:Unidoc.RedirectOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let vertex:Unidoc.DeclVertex = tests.expect(
                        value: output.matches.first?.decl)
                {
                    tests.expect(vertex.stem.last ==? "init(bitPattern:)")
                }
            }
        }

        if  let tests:TestGroup = tests / "Parentheses"
        {
            for (name, query):(String, Unidoc.VertexQuery<Unidoc.LookupAdjacent>) in
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
                let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = tests.expect(
                    value: query)
                else
                {
                    continue
                }
                await tests.do
                {
                    if  let output:Unidoc.VertexOutput = tests.expect(
                            value: try await session.query(database: unidoc.id, with: query)),
                        let _:Unidoc.AnyVertex = tests.expect(value: output.principal?.vertex)
                    {
                    }
                }
            }
        }

        if  let tests:TestGroup = tests / "BarbieCore"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift-malibu", ["barbiecore"])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let vertex:Unidoc.CultureVertex = tests.expect(
                        value: output.principal?.vertex?.culture),
                    let tree:Unidoc.TypeTree = tests.expect(
                        value: output.principal?.tree)
                {
                    tests.expect(vertex.id ==? tree.id)
                    tests.expect(tree.rows ..?
                        [
                            .init(
                                shoot: .init(stem: "BarbieCore External-links"),
                                type: .text("External links")),
                            .init(
                                shoot: .init(stem: "BarbieCore Getting-started"),
                                type: .text("Getting started")),
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie"),
                                type: .stem(.culture, .swift(.enum))),
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie ID"),
                                type: .stem(.culture, .swift(.struct))),
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie PlasticKeychain"),
                                type: .stem(.culture, .swift(.struct))),
                        ])
                }
            }
        }

        /// The ``Barbie.Dreamhouse`` type has a doccomment with many cross-module
        /// and cross-package references. We should be able to resolve all of them.
        /// The type itself lives in ``BarbieHousing``, but it is namespaced to
        /// ``BarbieCore.Barbie``, and its codelinks should resolve relative to that
        /// namespace.
        for case (let tests?, let path, let expected) in
        [
            (
                tests / "Barbie" / "Dreamhouse" as TestGroup?,
                ["barbiecore", "barbie", "dreamhouse"][...],
                [
                    "Int": 1,
                    "Int max": 2,
                    "ID": 1,
                    "Barbie": 1,
                    "Barbie ID": 2,
                    "BarbieCore Barbie ID": 3,
                ] as [String: Int]
            ),
            (
                tests / "Barbie" / "Dreamhouse" / "Keys" as TestGroup?,
                ["barbiecore", "barbie", "dreamhouse", "keys"][...],
                [
                    "Int": 1,
                    "max": 2, // expands to two components because it is a vector symbol
                    "ID": 1,
                    "Barbie": 1,
                ] as [String: Int]
            ),
        ]
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("swift-malibu", path)
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let vertex:Unidoc.AnyVertex = tests.expect(
                        value: output.principal?.vertex),
                    let tree:Unidoc.TypeTree = tests.expect(
                        value: output.principal?.tree),
                    let overview:Unidoc.Passage = tests.expect(
                        value: vertex.overview)
                {
                    //  This checks that we cached the two instances of `Barbie.ID`, and
                    //  additionally that we optimized away a third reference to it.
                    tests.expect(overview.outlines.count ==? expected.count)
                    tests.expect(tree.rows ..?
                        [
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie"),
                                type: .stem(.package, .swift(.enum))),
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie Dreamhouse"),
                                type: .stem(.culture, .swift(.enum))),
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie Dreamhouse Keys"),
                                type: .stem(.culture, .swift(.struct))),
                            .init(
                                shoot: .init(stem: "BarbieCore Barbie PlasticKeychain"),
                                type: .stem(.package, .swift(.struct))),
                            .init(
                                shoot: .init(stem: "Swift Array"),
                                type: .stem(.foreign, .swift(.struct))),
                        ])

                    let secondaries:Set<Unidoc.Scalar> = .init(output.vertices.lazy.map(\.id))
                    let lengths:[String: Int] = overview.outlines.reduce(into: [:])
                    {
                        guard
                        case .path(let words, let path) = $1
                        else
                        {
                            tests.expect(value: nil as [Unidoc.Scalar]?)
                            return
                        }
                        for id:Unidoc.Scalar in path
                        {
                            tests.expect(true: secondaries.contains(id))
                        }

                        {
                            tests.expect(nil: $0)
                            $0 = path.count
                        } (&$0[words])
                    }
                    //  The ``Int.max`` test case is especially valuable because not only is it
                    //  a multi-component cross-package reference, but the `max` member is also
                    //  being inherited from ``SignedInteger``.
                    tests.expect(lengths ==? expected)
                }
            }
        }
        /// The symbol graph linker should have mangled the space in `Getting started.md`
        /// into a hyphen.
        if  let tests:TestGroup = tests / "Barbie" / "GettingStarted"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift-malibu", ["barbiecore", "getting-started"])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let _:Unidoc.AnyVertex = tests.expect(
                        value: output.principal?.vertex)
                {
                }
            }
        }

        if  let tests:TestGroup = tests / "Barbie" / "ExternalLinks"
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift-malibu", ["barbiecore", "external-links"])
            await tests.do
            {
                if  let output:Unidoc.VertexOutput = tests.expect(
                        value: try await session.query(database: unidoc.id, with: query)),
                    let vertex:Unidoc.AnyVertex = tests.expect(
                        value: output.principal?.vertex),
                    let prose:Unidoc.Passage = tests.expect(
                            value: vertex.overview)
                {
                    //  Note: the duplicate outline was not optimized away because external
                    //  links are resolved dynamically, and this means their representation
                    //  within symbol graphs encodes their source locations, for diagnostics.
                    tests.expect(prose.outlines.count ==? 4)
                    tests.expect(prose.outlines[..<3] ..? [
                            .link(https: "en.wikipedia.org/wiki/Main_Page", safe: true),
                            .link(https: "en.wikipedia.org/wiki/Main_Page", safe: true),
                            .link(https: "liberationnews.org", safe: false),
                        ])

                    guard
                    case .path(let text, let path) = prose.outlines[3]
                    else
                    {
                        tests.expect(value: nil as [Unidoc.Scalar]?)
                        return
                    }

                    //  TODO: This is not a bug, but it is a missed optimization opportunity.
                    //  We do not need to resolve the two leading path components, as they will
                    //  never be shown to the user.
                    tests.expect(text ==? "swift string index")
                    tests.expect(path.count ==? 3)
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
                    filter: .curators)
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
