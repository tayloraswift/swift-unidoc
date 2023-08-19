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

        let trees:[Record.NounTree] = types.trees()
        let map:Record.NounMap = .init(id: self.zone.id, from: trees, for: modules)

        return (map, trees)
    }
}
