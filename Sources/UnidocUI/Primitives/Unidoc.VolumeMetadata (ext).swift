import HTML
import UnidocRecords

extension Unidoc.VolumeMetadata
{
    var title:String
    {
        self.display ?? "\(self.symbol.package)"
    }

    /// Generates a subdomain header for a module using its shoot.
    ///
    /// FIXME: this is sort of a hack, but it works for now. The string displayed in the link
    /// text will be the mangled module name, rather than the module’s actual name.
    func subdomain(_ module:Unidoc.Route) -> Unidoc.VertexDomain?
    {
        let module:Unidoc.VertexDomain.Module = .init(name: module.stem.first,
            url: "\(Unidoc.DocsEndpoint[self, module])")
        return .init(volume: self, module: module)
    }

    static
    func | (self:Unidoc.VolumeMetadata, _:Never?) -> Unidoc.VertexDomain?
    {
        .init(volume: self)
    }

    static
    func | (
        self:Unidoc.VolumeMetadata,
        link:Unidoc.LinkReference<Unidoc.CultureVertex>) -> Unidoc.VertexDomain?
    {
        guard
        let module:Unidoc.VertexDomain.Module = .init(from: link)
        else
        {
            return nil
        }

        return .init(volume: self, module: module)
    }

    static
    func | (
        self:Unidoc.VolumeMetadata,
        link:
        (
            culture:Unidoc.LinkReference<Unidoc.CultureVertex>,
            extends:Unidoc.LinkReference<Unidoc.CultureVertex>?
        )) -> Unidoc.VertexDomain?
    {
        guard
        let module:Unidoc.VertexDomain.Module = .init(from: link.culture)
        else
        {
            return nil
        }

        if  let colony:Unidoc.LinkReference<Unidoc.CultureVertex> = link.extends,
            let colony:Unidoc.VertexDomain.Module = .init(from: colony)
        {
            return .init(volume: self, module: module, colony: colony)
        }
        else
        {
            return .init(volume: self, module: module)
        }
    }
}
