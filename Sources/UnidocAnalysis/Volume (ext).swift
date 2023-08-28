import FNV1
import ModuleGraphs
import Unidoc
import UnidocRecords

@available(*, deprecated, renamed: "Volume")
public typealias Records = Volume

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
    func indexes() -> (SearchIndex<VolumeIdentifier>, [NounTree])
    {
        var modules:[Unidoc.Scalar: ModuleIdentifier] = [:]
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
                case _:
                    continue
                }

            case .file, .meta:
                continue
            }
        }

        let nounTrees:[NounTree] = types.trees()
        let nounMap:SearchIndex<VolumeIdentifier> = .nouns(id: self.id,
            from: nounTrees,
            for: modules)

        return (nounMap, nounTrees)
    }
}
