import HTML
import LexicalPaths
import ModuleGraphs
import Signatures
import Unidoc
import UnidocRecords

final
class Inliner
{
    var masters:Masters
    private
    var cache:Cache

    private
    init(masters:Masters, zones:Zones)
    {
        self.masters = masters
        self.cache = .init(zones: zones)
    }
}
extension Inliner
{
    var zones:Zones
    {
        _read   { yield  self.cache.zones }
        _modify { yield &self.cache.zones }
    }
}
extension Inliner
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
extension Inliner
{
    func code(_ snippet:Signature<Unidoc.Scalar?>.Expanded) -> DynamicCode
    {
        .init(bytecode: snippet.bytecode, scalars: snippet.scalars, inliner: self)
    }
    func prose(_ passage:Record.Passage) -> DynamicProse
    {
        .init(passage: passage, inliner: self)
    }
}
extension Inliner
{
    func card(_ scalar:Unidoc.Scalar) -> DynamicCard?
    {
        self.masters[scalar].map
        {
            .init(overview: $0.overview.map(self.prose(_:)),
                master: $0,
                target: self.cache[scalar, $0])
        }
    }
}
extension Inliner
{
    func link(module:Unidoc.Scalar) -> HTML.Link<ModuleIdentifier>?
    {
        if  case .culture(let master)? = self.masters[module]
        {
            return .init(display: master.module.id, target: self.cache[module, master])
        }
        else
        {
            return nil
        }
    }
    func link(decl:Unidoc.Scalar) -> HTML.Link<UnqualifiedPath>?
    {
        if  case .decl(let master)? = self.masters[decl],
            let path:UnqualifiedPath = .init(splitting: master.stem)
        {
            return .init(display: path, target: self.cache[decl, master])
        }
        else
        {
            return nil
        }
    }
}
extension Inliner
{
    func link<Scalars>(_ display:[Substring],
        to scalars:Scalars) -> DynamicVectorLink<[Substring], Scalars>
        where Scalars:Sequence<Unidoc.Scalar>
    {
        .init(display: display, scalars: scalars, inliner: self)
    }
}
extension Inliner
{
    func uri(_ scalar:Unidoc.Scalar) -> String?
    {
        self.cache.load(scalar)
        {
            if  let master:Record.Master = self.masters[scalar]
            {
                return .init(master: master, in: $0)
            }
            else
            {
                return nil
            }
        }
    }
}
