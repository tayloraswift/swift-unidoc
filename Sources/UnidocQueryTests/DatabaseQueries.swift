import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import Unidoc
import UnidocDatabase
import UnidocQueries
import UnidocRecords
import UnidocSelectors

struct DatabaseQueries:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Database = try await .setup(database, in: pool)

        let workspace:Workspace = try await .create(at: ".testing")
        let toolchain:Toolchain = try await .detect()

        var example:Documentation = try await toolchain.generateDocs(
            for: try await .local(package: "swift-malibu",
                from: "TestPackages",
                in: workspace,
                clean: true),
            pretty: true)

        //  Cross-package features won’t work unless the snapshot has a
        //  semantic version number.
        example.metadata.version = .stable(.release(.v(0, 0, 0)))

        example.roundtrip(for: tests, in: workspace.path)

        let swift:Documentation
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

        tests.expect(try await database.publish(docs: swift, with: session) ==? .init(
            overwritten: false,
            package: 0,
            version: 0,
            id: "swift v5.8.1 x86_64-unknown-linux-gnu"))

        tests.expect(try await database.publish(docs: example, with: session) ==? .init(
            overwritten: false,
            package: 1,
            version: 0,
            id: "swift-malibu v0.0.0 x86_64-unknown-linux-gnu"))

        /// We should be able to resolve the ``Dictionary.Keys`` type without hashes.
        if  let tests:TestGroup = tests / "Dictionary" / "Keys"
        {
            let query:WideQuery = .init(.docs, "swift", ["swift", "dictionary", "keys"])
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let master:Record.Master.Decl = tests.expect(
                        value: output.principal?.master?.decl)
                {
                    tests.expect(master.stem.last ==? "Keys")
                }
            }
        }

        /// We should be able to get multiple results back for an ambiguous query.
        if  let tests:TestGroup = tests / "Int" / "init"
        {
            let query:WideQuery = .init(.docs, "swift", ["swift", "int.init(_:)"])
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let principal:WideQuery.Output.Principal = tests.expect(
                        value: output.principal),
                    tests.expect(principal.matches.count >? 1),
                    tests.expect(nil: principal.master)
                {
                }
            }
        }

        /// We should be able to disambiguate the previous query with an FNV-1 hash.
        if  let tests:TestGroup = tests / "Int" / "init" / "hashed"
        {
            let query:WideQuery = .init(.docs, "swift", ["swift", "int.init(_:)"],
                hash: .init("8VBWO"))
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let principal:WideQuery.Output.Principal = tests.expect(
                        value: output.principal),
                    let _:Record.Master = tests.expect(value: principal.master)
                {
                }
            }
        }

        /// We should be able to use a mangled decl identifier to obtain a redirect.
        if  let tests:TestGroup = tests / "Int" / "init" / "overload"
        {
            let query:ThinQuery<Selector.Precise> = .init(
                for: .init(.init(.s, ascii: "Si10bitPatternSiSO_tcfc")),
                in: .init("swift"))
            await tests.do
            {
                if  let output:ThinQuery<Selector.Precise>.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let master:Record.Master.Decl = tests.expect(
                        value: output.masters.first?.decl)
                {
                    tests.expect(master.stem.last ==? "init(bitPattern:)")
                }
            }
        }

        if  let tests:TestGroup = tests / "Parentheses"
        {
            for (name, query):(String, WideQuery) in
            [
                (
                    "None",
                    .init(.docs, "swift", ["swift", "bidirectionalcollection.reversed"])
                ),
                (
                    "Empty",
                    .init(.docs, "swift", ["swift", "bidirectionalcollection.reversed()"])
                ),
            ]
            {
                guard
                    let tests:TestGroup = tests / name,
                    let query:WideQuery = tests.expect(value: query)
                else
                {
                    continue
                }
                await tests.do
                {
                    if  let output:WideQuery.Output = tests.expect(
                            value: try await database.execute(query: query, with: session)),
                        let _:Record.Master = tests.expect(value: output.principal?.master)
                    {
                    }
                }
            }
        }

        if  let tests:TestGroup = tests / "BarbieCore"
        {
            let query:WideQuery = .init(.docs, "swift-malibu", ["barbiecore"])
            await tests.do
            {
                if  let output:WideQuery.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let master:Record.Master.Culture = tests.expect(
                        value: output.principal?.master?.culture),
                    let types:Record.TypeTree = tests.expect(
                        value: output.principal?.types)
                {
                    tests.expect(master.id ==? types.id)
                    tests.expect(types.rows ..?
                        [
                            .init(stem: "BarbieCore Barbie", top: true),
                            .init(stem: "BarbieCore Barbie ID", top: false),
                            .init(stem: "BarbieCore Barbie PlasticKeychain", top: false),
                            .init(stem: "BarbieCore Getting-Started", top: true),
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
            let query:WideQuery = .init(.docs, "swift-malibu",
                [
                    "barbiecore",
                    "barbie",
                    "dreamhouse"
                ])
            await tests.do
            {
                if  let output:WideQuery.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let master:Record.Master = tests.expect(
                        value: output.principal?.master),
                    let types:Record.TypeTree = tests.expect(
                        value: output.principal?.types),
                    let overview:Record.Passage = tests.expect(
                        value: master.overview),
                    tests.expect(overview.outlines.count ==? 5)
                {
                    tests.expect(types.rows ..?
                        [
                            .init(stem: "BarbieCore Barbie Dreamhouse", top: true),
                            .init(stem: "BarbieCore Barbie Dreamhouse Keys", top: false),
                        ])

                    let secondaries:Set<Unidoc.Scalar> = .init(output.secondary.lazy.map(\.id))

                    for outline:Record.Outline in overview.outlines
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
            let query:WideQuery = .init(.article, "swift-malibu",
                [
                    "barbiecore",
                    "getting-started",
                ])
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await database.execute(query: query, with: session)),
                    let _:Record.Master = tests.expect(
                        value: output.principal?.master)
                {
                }
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
            for (name, query):(String, WideQuery) in
            [
                (
                    "Upstream",
                    .init(.docs, "swift", ["swift", "array"])
                ),
                (
                    "Local",
                    .init(.docs, "swift-malibu",
                    [
                        "barbiecore",
                        "barbie",
                        "plastickeychain"
                    ])
                ),
            ]
            {
                guard
                    let tests:TestGroup = tests / name,
                    let query:WideQuery = tests.expect(value: query)
                else
                {
                    continue
                }
                await tests.do
                {

                    if  let output:WideQuery.Output = tests.expect(
                            value: try await database.execute(query: query, with: session)),
                        let _:Record.Master = tests.expect(value: output.principal?.master)
                    {
                        let secondaries:[Unidoc.Scalar: Substring] = output.secondary.reduce(
                            into: [:])
                        {
                            $0[$1.id] = $1.stem?.last
                        }
                        var counts:[Substring: Int] = [:]
                        for case .extension(let `extension`) in output.principal?.groups ?? []
                        {
                            for p:Unidoc.Scalar in `extension`.conformances
                            {
                                counts[secondaries[p] ?? "", default: 0] += 1
                            }
                            for f:Unidoc.Scalar in `extension`.features
                            {
                                counts[secondaries[f] ?? "", default: 0] += 1
                            }
                        }

                        for name:String in
                        [
                            "Sequence",
                            "Collection",
                            "BidirectionalCollection",
                            "RandomAccessCollection",
                            "DollhouseKeychain",
                            "suffix(from:)",
                            "find(for:)",
                        ]
                        {
                            (tests / name)?.expect(counts[name[...], default: 0] ==? 1)
                        }
                    }
                }
            }
        }
    }
}
