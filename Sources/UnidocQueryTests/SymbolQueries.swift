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
import UnidocSelectors

struct SymbolQueries:UnidocDatabaseTestBattery
{
    func run(_ tests:TestGroup,
        accounts:AccountDatabase,
        unidoc:UnidocDatabase,
        pool:Mongo.SessionPool) async throws
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

        tests.expect(try await unidoc.publish(consume swift, with: session) ==?
            .init(id: .init(package: .swift,
                    version: "5.9.0",
                    triple: toolchain.triple),
                edition: .init(package: 0, version: 0),
                type: .insert))

        tests.expect(try await unidoc.publish(consume example, with: session) ==?
            .init(id: .init(package: "swift-malibu",
                    version: "0.0.0",
                    triple: toolchain.triple),
                edition: .init(package: 1, version: -1),
                type: .insert))

        /// We should be able to resolve the ``Dictionary.Keys`` type without hashes.
        if  let tests:TestGroup = tests / "Dictionary" / "Keys"
        {
            let query:WideQuery = .init("swift", ["swift", "dictionary", "keys"])
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
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
            let query:WideQuery = .init("swift", ["swift", "int.init(_:)"])
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let principal:WideQuery.Output.Principal = tests.expect(
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
            let query:WideQuery = .init("swift", ["swift", "int.init(_:)"],
                hash: .init("8VBWO"))
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let principal:WideQuery.Output.Principal = tests.expect(
                        value: output.principal),
                    let _:Volume.Vertex = tests.expect(value: principal.vertex)
                {
                }
            }
        }

        /// We should be able to use a mangled decl identifier to obtain a redirect.
        if  let tests:TestGroup = tests / "Int" / "init" / "overload"
        {
            let query:ThinQuery<Symbol.Decl> = .init(
                volume: .init(package: "swift", version: nil),
                lookup: .init(.s, ascii: "Si10bitPatternSiSO_tcfc"))

            await tests.do
            {
                if  let output:ThinQuery<Symbol.Decl>.Output = tests.expect(
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
            for (name, query):(String, WideQuery) in
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
                    let query:WideQuery = tests.expect(value: query)
                else
                {
                    continue
                }
                await tests.do
                {
                    if  let output:WideQuery.Output = tests.expect(
                            value: try await unidoc.execute(query: query, with: session)),
                        let _:Volume.Vertex = tests.expect(value: output.principal?.vertex)
                    {
                    }
                }
            }
        }

        if  let tests:TestGroup = tests / "BarbieCore"
        {
            let query:WideQuery = .init("swift-malibu", ["barbiecore"])
            await tests.do
            {
                if  let output:WideQuery.Output = tests.expect(
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
            let query:WideQuery = .init("swift-malibu", ["barbiecore", "barbie", "dreamhouse"])
            await tests.do
            {
                if  let output:WideQuery.Output = tests.expect(
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
            let query:WideQuery = .init("swift-malibu", ["barbiecore", "getting-started"])
            await tests.do
            {

                if  let output:WideQuery.Output = tests.expect(
                        value: try await unidoc.execute(query: query, with: session)),
                    let _:Volume.Vertex = tests.expect(
                        value: output.principal?.vertex)
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
                    .init("swift", ["swift", "array"])
                ),
                (
                    "Local",
                    .init("swift-malibu", ["barbiecore", "barbie", "plastickeychain"])
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
                            value: try await unidoc.execute(query: query, with: session)),
                        let _:Volume.Vertex = tests.expect(value: output.principal?.vertex)
                    {
                        let secondaries:[Unidoc.Scalar: Substring] = output.vertices.reduce(
                            into: [:])
                        {
                            $0[$1.id] = $1.shoot?.stem.last
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
