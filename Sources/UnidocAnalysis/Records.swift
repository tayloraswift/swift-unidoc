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
        var levels:[Unidoc.Scalar: TypeLevels] = [:]
        for master:Record.Master in self.masters
        {
            let culture:Unidoc.Scalar
            let scope:Unidoc.Scalar?
            let node:TypeLevels.Node
            switch master
            {
            case .article(let master):
                culture = master.culture
                scope = nil
                node = .init(shoot: master.shoot)

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
                scope = master.scope.last
                node = .init(shoot: master.shoot)

            case .file:
                continue
            }

            levels[culture, default: .init()][node.shoot.stem.depth, master.id] = (scope, node)
        }

        //  TODO: include extended types

        var trees:[Record.NounTree] = []
            trees.reserveCapacity(levels.count)

        var l:Dictionary<Unidoc.Scalar, TypeLevels>.Index = levels.startIndex
        while   l < levels.endIndex
        {
            defer
            {
                l = levels.index(after: l)
            }

            levels.values[l].collapse()

            let (culture, levels):(Unidoc.Scalar, TypeLevels) = levels[l]

            trees.append(.init(id: culture,
                top: levels.top.values.sorted { $0.shoot.stem < $1.shoot.stem }))
        }

        let nouns:Record.NounMap = .init(id: self.zone.id, from: trees, for: modules)

        return (nouns, trees)
    }
}
