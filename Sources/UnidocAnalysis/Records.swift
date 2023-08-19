import FNV1
import ModuleGraphs
import Unidoc
import UnidocRecords

@frozen public
struct Records
{
    public
    var latest:Unidoc.Zone?

    public
    var masters:[Record.Master]
    public
    var groups:[Record.Group]
    public
    var zone:Record.Zone

    @inlinable public
    init(latest:Unidoc.Zone?,
        masters:[Record.Master],
        groups:[Record.Group],
        zone:Record.Zone)
    {
        self.latest = latest

        self.masters = masters
        self.groups = groups
        self.zone = zone
    }
}
extension Records
{
    public
    func siteMap(for id:PackageIdentifier) -> Record.SiteMap<PackageIdentifier>
    {
        var lines:[UInt8] = []
        for master:Record.Master in self.masters
        {
            switch master
            {
            case .culture(let master):
                master.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .article(let master):
                master.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .decl(let master):
                master.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .file:
                break
            }
        }

        return .init(id: id, lines: lines)
    }
    public
    func indexes() -> (Record.NounMap, [Record.NounTree])
    {
        var modules:[Unidoc.Scalar: ModuleIdentifier] = [:]
        var types:Types = .init()

        for master:Record.Master in self.masters
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
                    break
                }

            case .file:
                break
            }
        }

        //  TODO: include extended types

        let nounTrees:[Record.NounTree] = types.trees()
        let nounMap:Record.NounMap = .init(id: self.zone.id, from: nounTrees, for: modules)

        return (nounMap, nounTrees)
    }
}

