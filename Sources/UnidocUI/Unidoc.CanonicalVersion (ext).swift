import HTML
import SemanticVersions
import UnidocRender
import URI

extension Unidoc.CanonicalVersion
{
    init?(principal:Unidoc.PrincipalOutput,
        vertex:__shared Unidoc.AnyVertex?,
        layer:(some Unidoc.VertexLayer).Type)
    {
        guard
        let volumeOfLatest:Unidoc.VolumeMetadata = principal.volumeOfLatest,
        let patchOfLatest:PatchVersion = volumeOfLatest.patch
        else
        {
            return nil
        }

        //  This can happen if you visit the latest stable release explicitly in the URL bar.
        if  principal.volume.id == volumeOfLatest.id
        {
            return nil
        }

        let relationship:Relationship
        if  let origin:PatchVersion = principal.volume.patch
        {
            relationship = origin < patchOfLatest ? .later : .earlier
        }
        else
        {
            relationship = .stable
        }

        let target:Target

        if  let vertex:Unidoc.AnyVertex
        {
            switch vertex
            {
            case .article(let vertex):
                target = .article(layer[volumeOfLatest, vertex.route])

            case .culture(let vertex):
                target = .culture(layer[volumeOfLatest, vertex.route])

            case .decl(let vertex):
                target = .decl(layer[volumeOfLatest, vertex.route])

            case .file:
                return nil

            case .product(let vertex):
                target = .product(layer[volumeOfLatest, vertex.route])

            case .foreign(let vertex):
                target = .foreign(layer[volumeOfLatest, vertex.route])

            case .landing:
                target = .landing
            }
        }
        else
        {
            switch principal.vertex
            {
            case .article?:     target = .article(nil)
            case .culture?:     target = .culture(nil)
            case .decl?:        target = .decl(nil)
            case .file?, nil:   return   nil
            case .product?:     target = .product(nil)
            case .foreign?:     target = .foreign(nil)
            case .landing?:     target = .landing
            }
        }

        self.init(relationship: relationship,
            package: volumeOfLatest.title,
            volume: Unidoc.DocsEndpoint[volumeOfLatest], // this does *not* use `layer`!
            target: target)
    }
}
extension Unidoc.CanonicalVersion
{
    @inlinable
    var uri:URI?
    {
        switch self.target
        {
        case .article(let uri): uri
        case .culture(let uri): uri
        case .decl(let uri):    uri
        case .product(let uri): uri
        case .foreign(let uri): uri
        case .landing:          self.volume
        }
    }
}
extension Unidoc.CanonicalVersion:HTML.OutputStreamable
{
    public static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        switch self.relationship
        {
        case .earlier:
            section[.p]
            {
                $0 += "You’re reading documentation from a "
                $0[.em] = "prerelease"
                $0 += " version of \(self.package)."
            }

        case .stable:
            section[.p]
            {
                $0 += "You’re reading documentation from an "
                $0[.em] = "experimental"
                $0 += " version of \(self.package)."
            }

        case .later:
            section[.p]
            {
                $0 += "You’re reading documentation from an "
                $0[.em] = "older"
                $0 += " version of \(self.package)."
            }
        }

        if  case .landing = self.target
        {
            section[.p]
            {
                $0 += "Read the documentation for the "
                $0[.a] { $0.href = "\(self.volume)" } = "latest stable release"
                $0 += " instead."
            }
            return
        }

        if  let uri:URI = self.target.uri
        {
            section[.p]
            {
                $0[.a] { $0.href = "\(uri)" } = """
                \(self.target.indefiniteArticle) \(self.target.demonym) with the same \
                \(self.target.identity)
                """
                $0 += " as this one exists in the "
                $0[.a] { $0.href = "\(self.volume)" } = "latest stable release"
                $0 += " of \(self.package)."
            }
        }
        else
        {
            section[.p]
            {
                switch self.relationship
                {
                case .earlier, .stable:
                    $0 += """
                    This \(self.target.demonym) might be new or have a different \
                    \(self.target.identity) from its predecessor in the \

                    """

                case .later:
                    $0 += """
                    This \(self.target.demonym) may have changed its \
                    \(self.target.identity) in the \

                    """
                }

                $0[.a] { $0.href = "\(self.volume)" } = "latest stable release"
                $0 += " of \(self.package)."
            }
        }
    }
}
