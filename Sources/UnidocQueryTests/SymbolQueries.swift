import MongoDB
import SymbolGraphs
import SymbolGraphTesting
import Symbols
import System_
import Testing
import Unidoc
@_spi(testable)
import UnidocDB
import UnidocQueries
import UnidocRecords

@Suite
struct SymbolQueries:Unidoc.TestBattery
{
    @Test
    func symbolQueries() async throws
    {
        try await self.run(in: "SymbolQueries")
    }

    func run(with db:Unidoc.DB) async throws
    {
        let directory:FilePath.Directory = "TestPackages"
        //  Use pre-built symbol graphs for speed.
        let example:SymbolGraphObject<Void> = try .load(package: "swift-malibu", in: directory)
        try example.roundtrip(in: directory)

        let swift:SymbolGraphObject<Void> = try .load(package: .swift, in: directory)

        #expect(try await db.store(linking: swift).0 == .init(
            edition: .init(package: 0, version: 0),
            updated: false))

        #expect(try await db.store(linking: example).0 == .init(
            edition: .init(package: 1, version: -1),
            updated: false))

        /// We should be able to resolve the ``Dictionary.Keys`` type without hashes.
        do
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift", ["swift", "dictionary", "keys"])

            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))
            let vertex:Unidoc.DeclVertex = try #require(output.principalVertex?.decl)

            #expect(vertex.stem.last == "Keys")
        }
        do
        {
            /// We should be able to get multiple results back for an ambiguous query.
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift", ["swift", "int.init(_:)"])

            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))

            #expect(output.matches.count > 1)
            #expect(output.principalVertex == nil)
        }
        do
        {
            /// We should be able to disambiguate the previous query with an FNV-1 hash.
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift", ["swift", "int.init(_:)"],
                hash: .init("8VBWO"))

            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))
            #expect(output.principalVertex != nil)
        }
        do
        {
            /// We should be able to use a mangled decl identifier to obtain a redirect.
            let query:Unidoc.RedirectBySymbolicHintQuery<Symbol.Decl> = .init(
                volume: .init(package: "swift", version: nil),
                lookup: .init(.s, ascii: "Si10bitPatternSiSO_tcfc"))

            let output:Unidoc.RedirectOutput = try #require(try await db.query(with: query))
            let vertex:Unidoc.DeclVertex = try #require(output.matches.first?.decl)

            #expect(vertex.stem.last == "init(bitPattern:)")
        }

        for query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> in [
            .init("swift", ["swift", "bidirectionalcollection.reversed()"]),
            .init("swift", ["swift", "bidirectionalcollection.reversed"]),
        ]
        {
            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))
            let vertex:Unidoc.DeclVertex = try #require(output.principalVertex?.decl)

            #expect(vertex.stem.last == "reversed")
        }

        do
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift-malibu", ["barbiecore"])

            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))
            let vertex:Unidoc.CultureVertex = try #require(output.principalVertex?.culture)
            let tree:Unidoc.TypeTree = try #require(output.tree)

            #expect(vertex.id == tree.id)
            #expect(tree.rows == [
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

        /// The ``Barbie.Dreamhouse`` type has a doccomment with many cross-module
        /// and cross-package references. We should be able to resolve all of them.
        /// The type itself lives in ``BarbieHousing``, but it is namespaced to
        /// ``BarbieCore.Barbie``, and its codelinks should resolve relative to that
        /// namespace.
        for (path, expected):(ArraySlice<String>, [String: Int]) in [
            (
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
                ["barbiecore", "barbie", "dreamhouse", "keys"][...],
                [
                    "Int": 1,
                    "max": 1,
                    "ID": 1,
                    "Barbie": 1,
                ] as [String: Int]
            ),
        ]
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init("swift-malibu", path)
            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))
            let vertex:Unidoc.AnyVertex = try #require(output.principalVertex)
            let tree:Unidoc.TypeTree = try #require(output.tree)
            let overview:Unidoc.Passage = try #require(vertex.overview)

            //  This checks that we cached the two instances of `Barbie.ID`, and
            //  additionally that we optimized away a third reference to it.
            #expect(overview.outlines.count == expected.count)
            #expect(tree.rows == [
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

            let secondaries:Set<Unidoc.Scalar> = output.adjacentVertices.reduce(into: [])
            {
                $0.insert($1.id)
            }
            let lengths:[String: Int] = overview.outlines.reduce(into: [:])
            {
                guard
                case .path(let text, let path) = $1
                else
                {
                    Issue.record()
                    return
                }
                for id:Unidoc.Scalar in path
                {
                    #expect(secondaries.contains(id))
                }

                {
                    #expect($0 == nil)
                    $0 = path.count
                } (&$0["\(text)"])
            }

            //  The ``Int.max`` test case is especially valuable because not only is it
            //  a multi-component cross-package reference, but the `max` member is also
            //  being inherited from ``SignedInteger``.
            #expect(lengths == expected)
        }
        /// The symbol graph linker should have mangled the space in `Getting started.md`
        /// into a hyphen.
        do
        {
            let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
                "swift-malibu", ["barbiecore", "getting-started"])

            let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))
            let _:Unidoc.AnyVertex = try #require(output.principalVertex)
        }

        try await self.test("SeeAlsoGeneratedFromTopics",
            running: .init("swift-malibu", [
                    "barbiecore",
                    "barbie",
                    "plastickeychain.startindex"
                ]),
            expect: ["endIndex", "startIndex"],
            except: ["subscript(_:)"],
            filter: [.curators],
            on: db)

        /// The ``BarbieHousing`` module vends an extension on ``Array`` that
        /// conforms it to the ``DollhouseSecurity.DollhouseKeychain`` protocol.
        /// The database should return this conformance as an extension on ``Array``,
        /// and it should not duplicate the features or conformances that already
        /// exist on ``Array``.
        ///
        /// The database should also perform the same de-duplication for
        /// conformances within the same package.
        try await self.test("Deduplication",
            running: .init("swift", ["swift", "array"]),
            expect: [
                "Sequence",
                "Collection",
                "BidirectionalCollection",
                "RandomAccessCollection",
                "suffix(from:)",
            ],
            except: [
                "DollhouseKeychain",
                "find(for:)",
            ],
            filter: [.extensions],
            on: db)

        try await self.test("PlasticKeychain",
            running: .init("swift-malibu", ["barbiecore", "barbie", "plastickeychain"]),
            expect: [
                "Sequence",
                "Collection",
                "BidirectionalCollection",
                "RandomAccessCollection",
                "suffix(from:)",

                "DollhouseKeychain",
                "find(for:)",
            ],
            filter: [.extensions],
            on: db)

        /// These tests are destructive, so we run them last.
        let realm:Unidoc.Realm
        do
        {
            let (metadata, new):(Unidoc.RealmMetadata, Bool) = try await db.index(
                realm: "barbieland")

            #expect(new)
            #expect(metadata.id == 0)
            #expect(metadata.symbol == "barbieland")

            realm = metadata.id
        }

        try await db.align(package: 0, realm: realm)
        try await db.align(package: 1, realm: realm)

        try await self.test("RealmContainingBoth",
            running: .init("swift", ["swift", "array"]),
            expect: [
                "Sequence",
                "Collection",
                "BidirectionalCollection",
                "RandomAccessCollection",
                "suffix(from:)",

                "DollhouseKeychain",
                "find(for:)",
            ],
            filter: [.extensions],
            on: db)

        try await db.align(package: 0, realm: realm)
        try await db.align(package: 1, realm: nil)

        try await self.test("RealmContainingStandardLibrary",
            running: .init("swift", ["swift", "array"]),
            expect: [
                "Sequence",
                "Collection",
                "BidirectionalCollection",
                "RandomAccessCollection",
                "suffix(from:)",
            ],
            except: [
                "DollhouseKeychain",
                "find(for:)",
            ],
            filter: [.extensions],
            on: db)

        try await db.align(package: 0, realm: nil)
        try await db.align(package: 1, realm: realm)

        try await self.test("RealmContainingPackage",
            running: .init("swift", ["swift", "array"]),
            expect: [
                "Sequence",
                "Collection",
                "BidirectionalCollection",
                "RandomAccessCollection",
                "suffix(from:)",
            ],
            except: [
                "DollhouseKeychain",
                "find(for:)",
            ],
            filter: [.extensions],
            on: db)

        try await db.align(package: 0, realm: nil)
        try await db.align(package: 1, realm: nil)

        try await self.test("RealmContainingNeither",
            running: .init("swift", ["swift", "array"]),
            expect: [
                "Sequence",
                "Collection",
                "BidirectionalCollection",
                "RandomAccessCollection",
                "suffix(from:)",
            ],
            except: [
                "DollhouseKeychain",
                "find(for:)",
            ],
            filter: [.extensions],
            on: db)
    }

    private
    func test(_ name:String,
        running query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>,
        expect members:[String],
        except exclude:[String] = [],
        filter:Set<Filter>,
        on db:Unidoc.DB) async throws
    {
        let output:Unidoc.VertexOutput = try #require(try await db.query(with: query))

        #expect(output.principalVertex != nil)

        let secondaries:[Unidoc.Scalar: Substring] = output.adjacentVertices.reduce(
            into: [:])
        {
            $0[$1.id] = $1.shoot?.stem.last
        }
        var counts:[Substring: Int] = [:]
        for group:Unidoc.AnyGroup in output.principalGroups
        {
            switch group
            {
            case .conformer:
                continue

            case .curator(let t):
                guard filter.contains(.curators)
                else
                {
                    continue
                }
                for id:Unidoc.Scalar in t.items
                {
                    counts[secondaries[id] ?? "", default: 0] += 1
                }

            case .extension(let e):
                guard filter.contains(.extensions)
                else
                {
                    continue
                }

                for p:Unidoc.Scalar in e.conformances
                {
                    counts[secondaries[p] ?? "", default: 0] += 1
                }
                for f:Unidoc.Scalar in e.features
                {
                    counts[secondaries[f] ?? "", default: 0] += 1
                }
                for n:Unidoc.Scalar in e.nested
                {
                    counts[secondaries[n] ?? "", default: 0] += 1
                }
                for s:Unidoc.Scalar in e.subforms
                {
                    counts[secondaries[s] ?? "", default: 0] += 1
                }

            case .intrinsic(let i):
                guard filter.contains(.intrinsics)
                else
                {
                    continue
                }

                for m:Unidoc.Scalar in i.items
                {
                    counts[secondaries[m] ?? "", default: 0] += 1
                }
            }
        }

        for name:String in members
        {
            #expect(counts[name[...], default: 0] == 1)
        }
        for name:String in exclude
        {
            #expect(counts[name[...], default: 0] == 0)
        }
    }
}
