import FNV1
import ModuleGraphs
import Unidoc
import UnidocRecords

extension Volume
{
    public
    func siteMap() -> SiteMap<PackageIdentifier>
    {
        var lines:[UInt8] = []
        for master:Volume.Master in self.masters
        {
            switch master
            {
            case .culture(let master):
                master.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .article(let master):
                master.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .decl(let master):
                master.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .file, .meta:
                continue
            }
        }

        return .init(id: self.names.package, lines: lines)
    }
    public
    func indexes() -> (SearchIndex<VolumeIdentifier>, [TypeTree])
    {
        var modules:[Unidoc.Scalar: ModuleIdentifier] = [:]
        var procs:[Unidoc.Scalar: [Shoot]] = [:]
        var types:Types = .init()

        for master:Master in self.masters
        {
            switch master
            {
            case .culture(let master):
                modules[master.id] = master.module.id

            case .article(let master):
                types[master.culture, master.id] = .init(shoot: master.shoot)

            case .decl(let master):
                switch master.phylum
                {
                case .actor, .class, .struct, .enum, .protocol:
                    types[master.culture, master.id] = .init(
                        shoot: master.shoot,
                        scope: master.scope.last)

                case .func(nil), .var(nil):
                    //  Global procedures show up in search, but not in the type tree.
                    procs[master.culture, default: []].append(master.shoot)

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
