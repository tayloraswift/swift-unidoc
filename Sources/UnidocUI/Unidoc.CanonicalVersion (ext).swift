import HTML
import SemanticVersions
import UnidocRender
import URI

extension Unidoc.CanonicalVersion
{
    init?(principalVolume:__shared Unidoc.VolumeMetadata,
        principalVertex:__shared Unidoc.AnyVertex?,
        canonicalVolume:__shared Unidoc.VolumeMetadata?,
        canonicalVertex:__shared Unidoc.AnyVertex?,
        layer:(some Unidoc.VertexLayer).Type)
    {
        guard
        let canonicalVolume:Unidoc.VolumeMetadata,
        let canonicalPatch:PatchVersion = canonicalVolume.patch
        else
        {
            return nil
        }

        //  This can happen if you visit the latest stable release explicitly in the URL bar.
        if  principalVolume.id == canonicalVolume.id
        {
            return nil
        }

        let relationship:Relationship
        if  let origin:PatchVersion = principalVolume.patch
        {
            relationship = origin < canonicalPatch ? .later : .earlier
        }
        else
        {
            relationship = .stable
        }

        let target:Target

        if  let canonicalVertex:Unidoc.AnyVertex
        {
            switch canonicalVertex
            {
            case .article(let canonical):
                target = .article(layer[canonicalVolume, canonical.route])

            case .culture(let canonical):
                target = .culture(layer[canonicalVolume, canonical.route])

            case .decl(let canonical):
                target = .decl(layer[canonicalVolume, canonical.route])

            case .file:
                return nil

            case .product(let canonical):
                target = .product(layer[canonicalVolume, canonical.route])

            case .foreign(let canonical):
                target = .foreign(layer[canonicalVolume, canonical.route])

            case .landing:
                target = .landing
            }
        }
        else
        {
            switch principalVertex
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
            package: canonicalVolume.title,
            volume: Unidoc.DocsEndpoint[canonicalVolume], // this does *not* use `layer`!
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
