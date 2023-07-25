import MongoDB
import MongoTesting
import SymbolGraphBuilder
import SymbolGraphs
import Unidoc
import UnidocDatabase
import UnidocRecords

struct DatabaseQueries:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Database = try await .setup(database, in: pool)

        let workspace:Workspace = try await .create(at: ".testing")
        let toolchain:Toolchain = try await .detect()

        let example:Documentation = try await toolchain.generateDocs(
            for: try await .local(package: "swift-malibu",
                from: "TestPackages",
                in: workspace,
                clean: true),
            pretty: true)

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
            id: "$anonymous"))

        /// We should be able to resolve the ``Dictionary.Keys`` type without hashes.
        if  let tests:TestGroup = tests / "Dictionary" / "Keys",
            let query:DeepQuery = tests.expect(
                value: .init(.docs, "swift:swift", ["dictionary", "keys"]))
        {
            await tests.do
            {
                let output:[DeepQuery.Output] = try await database.execute(query: query,
                    with: session)

                if  tests.expect(output.count ==? 1),
                    tests.expect(output[0].principal.count ==? 1),
                    let _:Record.Master = tests.expect(value: output[0].principal[0].master)
                {
                }
            }
        }

        /// We should be able to get multiple results back for an ambiguous query.
        if  let tests:TestGroup = tests / "Int" / "init",
            let query:DeepQuery = tests.expect(
                value: .init(.docs, "swift:swift", ["int.init(_:)"]))
        {
            await tests.do
            {
                let output:[DeepQuery.Output] = try await database.execute(query: query,
                    with: session)

                if  tests.expect(output.count ==? 1),
                    tests.expect(output[0].principal.count ==? 1),
                    tests.expect(output[0].principal[0].matches.count >? 1),
                    tests.expect(nil: output[0].principal[0].master)
                {
                }
            }
        }

        /// We should be able to disambiguate the previous query with an FNV-1 hash.
        if  let tests:TestGroup = tests / "Int" / "init" / "hashed",
            let query:DeepQuery = tests.expect(
                value: .init(.docs, "swift:swift", ["int.init(_:)"], hash: .init("8VBWO")))
        {
            await tests.do
            {
                let output:[DeepQuery.Output] = try await database.execute(query: query,
                    with: session)

                if  tests.expect(output.count ==? 1),
                    tests.expect(output[0].principal.count ==? 1),
                    let _:Record.Master = tests.expect(value: output[0].principal[0].master)
                {
                }
            }
        }

        if  let tests:TestGroup = tests / "Parentheses"
        {
            for (name, query):(String, DeepQuery?) in
            [
                (
                    "None",
                    .init(.docs, "swift:swift", ["bidirectionalcollection.reversed"])
                ),
                (
                    "Empty",
                    .init(.docs, "swift:swift", ["bidirectionalcollection.reversed()"])
                ),
            ]
            {
                guard
                    let tests:TestGroup = tests / name,
                    let query:DeepQuery = tests.expect(value: query)
                else
                {
                    continue
                }
                await tests.do
                {
                    let output:[DeepQuery.Output] = try await database.execute(query: query,
                        with: session)

                    if  tests.expect(output.count ==? 1),
                        tests.expect(output[0].principal.count ==? 1),
                        let _:Record.Master = tests.expect(value: output[0].principal[0].master)
                    {
                    }
                }
            }
        }

        /// The ``Barbie.Dreamhouse`` type has a doccomment with many cross-module
        /// and cross-package references. We should be able to resolve all of them.
        /// The type itself lives in ``BarbieHousing``, but it is namespaced to
        /// ``BarbieCore.Barbie``, and its codelinks should resolve relative to that
        /// namespace.
        if  let tests:TestGroup = tests / "Barbie" / "Dreamhouse",
            let query:DeepQuery = tests.expect(
                value: .init(.docs, "swift-malibu",
                [
                    "$anonymous:barbiecore",
                    "barbie",
                    "dreamhouse"
                ]))
        {
            await tests.do
            {
                let output:[DeepQuery.Output] = try await database.execute(query: query,
                    with: session)

                if  tests.expect(output.count ==? 1),
                    tests.expect(output[0].principal.count ==? 1),
                    let master:Record.Master = tests.expect(
                        value: output[0].principal[0].master),
                    let overview:Record.Passage = tests.expect(
                        value: master.overview),
                    tests.expect(overview.outlines.count ==? 5)
                {
                    let secondaries:Set<Unidoc.Scalar> = .init(
                        output[0].secondary.lazy.map(\.id))

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
            for (name, query):(String, DeepQuery?) in
            [
                (
                    "Upstream",
                    .init(.docs, "swift:swift", ["array"])
                ),
                (
                    "Local",
                    .init(.docs, "swift-malibu",
                    [
                        "$anonymous:barbiecore",
                        "barbie",
                        "plastickeychain"
                    ])
                ),
            ]
            {
                guard
                    let tests:TestGroup = tests / name,
                    let query:DeepQuery = tests.expect(value: query)
                else
                {
                    continue
                }
                await tests.do
                {
                    let output:[DeepQuery.Output] = try await database.execute(query: query,
                        with: session)

                    if  tests.expect(output.count ==? 1),
                        tests.expect(output[0].principal.count ==? 1),
                        let _:Record.Master = tests.expect(value: output[0].principal[0].master)
                    {
                        let secondaries:[Unidoc.Scalar: Substring] = output[0].secondary.reduce(
                            into: [:])
                        {
                            $0[$1.id] = $1.stem?.last
                        }
                        var counts:[Substring: Int] = [:]
                        for `extension`:Record.Extension in output[0].principal[0].extensions
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
