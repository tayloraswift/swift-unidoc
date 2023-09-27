import FNV1
import JSONEncoding
import ModuleGraphs
import Unidoc
import UnidocRecords

extension Volume
{
    public
    func siteMap() -> SiteMap<PackageIdentifier>
    {
        var lines:[UInt8] = []
        for vertex:Vertex in self.vertices
        {
            switch vertex
            {
            case .culture(let vertex):
                vertex.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .article(let vertex):
                vertex.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .decl(let vertex):
                vertex.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .file, .meta:
                continue
            }
        }

        return .init(id: self.meta.symbol.package, lines: lines)
    }
    public
    func indexes() -> (SearchIndex<VolumeIdentifier>, [TypeTree])
    {
        var modules:[Unidoc.Scalar: ModuleIdentifier] = [:]
        var procs:[Unidoc.Scalar: [Shoot]] = [:]
        var types:Types = .init()

        for vertex:Vertex in self.vertices
        {
            switch vertex
            {
            case .culture(let vertex):
                modules[vertex.id] = vertex.module.id

            case .article(let vertex):
                types[vertex.culture, vertex.id] = .init(shoot: vertex.shoot)

            case .decl(let vertex):
                switch vertex.phylum
                {
                case .actor, .class, .struct, .enum, .protocol, .macro(.attached):
                    types[vertex.culture, vertex.id] = .init(
                        shoot: vertex.shoot,
                        scope: vertex.scope.last)

                case .func(nil), .var(nil), .macro(.freestanding):
                    //  Global procedures show up in search, but not in the type tree.
                    procs[vertex.culture, default: []].append(vertex.shoot)

                case _:
                    continue
                }

            case .file, .meta:
                continue
            }
        }

        let trees:[TypeTree] = types.trees()

        let json:JSON = .array
        {
            for tree:TypeTree in trees
            {
                guard let culture:ModuleIdentifier = modules[tree.id]
                else
                {
                    continue
                }

                $0[+, Any.self]
                {
                    $0["c"] = "\(culture)"
                    $0["n"]
                    {
                        for row:Noun in tree.rows where row.same != nil
                        {
                            $0[+, Any.self]
                            {
                                $0["s"] = row.shoot.stem.rawValue
                                $0["h"] = row.shoot.hash?.value
                            }
                        }
                        for shoot:Shoot in procs.removeValue(forKey: tree.id) ?? []
                        {
                            $0[+, Any.self]
                            {
                                $0["s"] = shoot.stem.rawValue
                                $0["h"] = shoot.hash?.value
                            }
                        }
                    }
                }
            }
            for (culture, procs):(Unidoc.Scalar, [Shoot]) in
                procs.sorted(by: { $0.key < $1.key })
            {
                guard let culture:ModuleIdentifier = modules[culture]
                else
                {
                    continue
                }

                $0[+, Any.self]
                {
                    $0["c"] = "\(culture)"
                    $0["n"]
                    {
                        for shoot:Shoot in procs
                        {
                            $0[+, Any.self]
                            {
                                $0["s"] = shoot.stem.rawValue
                                $0["h"] = shoot.hash?.value
                            }
                        }
                    }
                }
            }
        }

        let index:SearchIndex<VolumeIdentifier> = .init(id: self.id, json: json)

        return (index, trees)
    }
}
