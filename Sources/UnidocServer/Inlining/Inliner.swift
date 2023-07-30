import HTML
import LexicalPaths
import ModuleGraphs
import Signatures
import Unidoc
import UnidocRecords

final
class Inliner
{
    private
    var cache:InlinerCache

    private
    init(cache:InlinerCache)
    {
        self.cache = cache
    }
}
extension Inliner
{
    var masters:InlinerCache.Masters
    {
        _read   { yield  self.cache.masters }
        _modify { yield &self.cache.masters }
    }
    var zones:InlinerCache.Zones
    {
        _read   { yield  self.cache.zones }
        _modify { yield &self.cache.zones }
    }
}
extension Inliner
{
    convenience
    init(principal scalar:Unidoc.Scalar, zone trunk:Record.Trunk)
    {
        self.init(cache: .init(
            masters: .init(principal: scalar),
            zones: .init(principal: (scalar.zone, trunk))))
    }
    convenience
    init(principal zone:Unidoc.Zone, zone trunk:Record.Trunk)
    {
        self.init(cache: .init(
            masters: .init(principal: nil),
            zones: .init(principal: (zone, trunk))))
    }
}
extension Inliner
{
    func passage(_ passage:Record.Passage) -> Passage
    {
        .init(self, passage: passage)
    }
    func code(_ snippet:Signature<Unidoc.Scalar?>.Expanded) -> Code
    {
        .init(self, bytecode: snippet.bytecode, scalars: snippet.scalars)
    }
}
extension Inliner
{
    func card(_ scalar:Unidoc.Scalar) -> Card?
    {
        self.cache[scalar].map
        {
            .init(overview: $0.overview.map(self.passage(_:)),
                master: $0,
                target: $1)
        }
    }
}
extension Inliner
{
    func link<Display, Scalars>(
        _ display:Display,
        to scalars:Scalars) -> VectorLink<Display, Scalars>
        where Scalars:Sequence<Unidoc.Scalar>
    {
        .init(self, display: display, scalars: scalars)
    }
}
extension Inliner
{
    func link(module:Unidoc.Scalar) -> HTML.Link<ModuleIdentifier>?
    {
        self.cache[culture: module].map
        {
            .init(display: $0.module.id, target: $1)
        }
    }
    func link(decl:Unidoc.Scalar) -> HTML.Link<String>?
    {
        self.cache[decl: decl].map
        {
            let path:UnqualifiedPath? = .init(splitting: $0.stem)
            return .init(display: path?.description ?? "", target: $1)
        }
    }
    func link(file:Unidoc.Scalar, line:Int? = nil) -> HTML.SourceLink?
    {
        self.cache[file: file, line: line].map
        {
            .init(file: $0.symbol.last, line: line, target: $1)
        }
    }
}
extension Inliner
{
    func url(_ scalar:Unidoc.Scalar) -> String?
    {
        self.cache[scalar]?.url
    }
}
