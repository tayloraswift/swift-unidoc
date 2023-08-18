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
        var nouns:[Unidoc.Scalar: [Record.Noun]] = [:]

        for master:Record.Master in self.masters
        {
            let culture:Unidoc.Scalar
            let noun:Record.Noun
            switch master
            {
            case .article(let master):
                culture = master.culture
                noun = .init(shoot: master.shoot, top: true)

            case .culture(let master):
                modules[master.id] = master.module.id
                continue

            case .decl(let master):
                switch master.phylum
                {
                case .actor, .class, .struct, .enum, .protocol: break
                case _:                                         continue
                }

                culture = master.culture
                noun = .init(shoot: master.shoot, top: master.stem.depth < 2)

            case .file:
                continue
            }

            nouns[culture, default: []].append(noun)
        }

        //  TODO: include extended types

        let trees:[Record.NounTree] = nouns.map
        {
            .init(id: $0.key, rows: $0.value.sorted { $0.shoot < $1.shoot })
        }

        let map:Record.NounMap = .init(id: self.zone.id, from: trees, for: modules)

        return (map, trees)
    }
}
