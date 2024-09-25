import MongoDB
import Testing_
import Unidoc
import UnidocDB
import UnidocQueries
import UnidocRecords

extension SymbolQueries
{
    struct TestCase
    {
        let filters:Set<Filter>
        let members:[String]
        let nonmembers:[String]
        let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>
        let tests:TestGroup

        private
        init(
            filters:Set<Filter>,
            members:[String],
            nonmembers:[String],
            query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>,
            tests:TestGroup)
        {
            self.filters = filters
            self.members = members
            self.nonmembers = nonmembers
            self.query = query
            self.tests = tests
        }
    }
}
extension SymbolQueries.TestCase
{
    init?(_ tests:TestGroup?,
        package:String,
        path:[String],
        expecting members:[String],
        except nonmembers:[String] = [],
        filter:Filter...)
    {
        guard
        let tests:TestGroup
        else
        {
            return nil
        }

        self.init(
            filters: .init(filter),
            members: members,
            nonmembers: nonmembers,
            query: .init(package, path[...]),
            tests: tests)
    }

    func run(on db:Unidoc.DB) async
    {
        await self.tests.do
        {
            if  let output:Unidoc.VertexOutput = self.tests.expect(
                    value: try await db.query(with: self.query)),
                let _:Unidoc.AnyVertex = self.tests.expect(value: output.principal.vertex)
            {
                let secondaries:[Unidoc.Scalar: Substring] = output.vertices.reduce(
                    into: [:])
                {
                    $0[$1.id] = $1.shoot?.stem.last
                }
                var counts:[Substring: Int] = [:]
                for group:Unidoc.AnyGroup in output.principal.groups
                {
                    switch group
                    {
                    case .conformer:
                        continue

                    case .curator(let t):
                        guard self.filters.contains(.curators)
                        else
                        {
                            continue
                        }
                        for id:Unidoc.Scalar in t.items
                        {
                            counts[secondaries[id] ?? "", default: 0] += 1
                        }

                    case .extension(let e):
                        guard self.filters.contains(.extensions)
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
                        guard self.filters.contains(.intrinsics)
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

                for name:String in self.members
                {
                    (self.tests / name)?.expect(counts[name[...], default: 0] ==? 1)
                }
                for name:String in self.nonmembers
                {
                    (self.tests / name)?.expect(counts[name[...], default: 0] ==? 0)
                }
            }
        }
    }
}
