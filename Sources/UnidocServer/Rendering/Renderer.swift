import ModuleGraphs
import Signatures
import Unidoc
import UnidocRecords
import URI

final
class Renderer
{
    var masters:MasterIndex
    var zones:ZoneIndex

    private
    init(masters:MasterIndex, zones:ZoneIndex)
    {
        self.masters = masters
        self.zones = zones
    }
}
extension Renderer
{
    convenience
    init(principal scalar:Unidoc.Scalar, zone names:Record.Zone.Names)
    {
        self.init(
            masters: .init(principal: scalar),
            zones: .init(principal: (scalar.zone, names)))
    }
    convenience
    init(principal zone:Unidoc.Zone, zone names:Record.Zone.Names)
    {
        self.init(
            masters: .init(principal: nil),
            zones: .init(principal: (zone, names)))
    }
}
extension Renderer
{
    func code(_ snippet:Signature<Unidoc.Scalar?>.Expanded) -> Code
    {
        .init(self, bytecode: snippet.bytecode, links: snippet.links)
    }
    func prose(_ passage:Record.Passage) -> Prosaic
    {
        .init(self, passage: passage)
    }
    func prose(_ passage:Record.Passage?) -> Prosaic?
    {
        passage.map(self.prose(_:))
    }
}
extension Renderer
{
    func link(module:Unidoc.Scalar) -> Link<ModuleIdentifier>?
    {
        if  case .culture(let culture)? = self.masters[module]
        {
            return .init(display: culture.module.id, target: self.zones[module.zone].map
            {
                .init(culture: culture, in: $0)
            })
        }
        else
        {
            return nil
        }
    }
}
extension Renderer
{
    func link<Display>(_ display:Display, to scalar:Unidoc.Scalar) -> Link<Display>
    {
        .init(display: display, target: self.uri(scalar))
    }

    func link<Scalars>(_ display:[Substring],
        to scalars:Scalars) -> Link<[Substring]>.LazyVector<Scalars>
        where Scalars:Sequence<Unidoc.Scalar>
    {
        .init(self, display: display, scalars: scalars)
    }
}
extension Renderer
{
    func uri(_ scalar:Unidoc.Scalar) -> URI?
    {
        if  let master:Record.Master = self.masters[scalar],
            let zone:Record.Zone.Names = self.zones[scalar.zone]
        {
            return .init(master: master, in: zone)
        }
        else
        {
            return nil
        }
    }
}
