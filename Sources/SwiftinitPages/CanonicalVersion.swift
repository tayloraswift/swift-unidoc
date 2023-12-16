import HTML
import SemanticVersions
import UnidocQueries
import UnidocRecords
import URI

@frozen public
struct CanonicalVersion
{
    @usableFromInline internal
    let relationship:Relationship
    /// Human-oriented text to display as the name of the package.
    @usableFromInline internal
    let package:String
    /// URI to the trunk page of the canonical volume.
    @usableFromInline internal
    let volume:URI
    @usableFromInline internal
    let target:Target

    private
    init(relationship:Relationship, package:String, volume:URI, target:Target)
    {
        self.relationship = relationship
        self.package = package
        self.volume = volume
        self.target = target
    }
}
extension CanonicalVersion
{
    init?(principal:Unidoc.PrincipalOutput)
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

        if  let vertex:Unidoc.Vertex = principal.vertexInLatest
        {
            switch vertex
            {
            case .article(let vertex):
                target = .article(Swiftinit.Docs[volumeOfLatest, vertex.shoot])

            case .culture(let vertex):
                target = .culture(Swiftinit.Docs[volumeOfLatest, vertex.shoot])

            case .decl(let vertex):
                target = .decl(Swiftinit.Docs[volumeOfLatest, vertex.shoot])

            case .file:
                return nil

            case .foreign(let vertex):
                target = .foreign(Swiftinit.Docs[volumeOfLatest, vertex.shoot])

            case .global:
                target = .global
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
            case .foreign?:     target = .foreign(nil)
            case .global?:      target = .global
            }
        }

        self.init(relationship: relationship,
            package: volumeOfLatest.title,
            volume: Swiftinit.Docs[volumeOfLatest],
            target: target)
    }
}
extension CanonicalVersion
{
    @inlinable internal
    var uri:URI?
    {
        switch self.target
        {
        case .article(let uri): uri
        case .culture(let uri): uri
        case .decl(let uri):    uri
        case .foreign(let uri): uri
        case .global:           self.volume
        }
    }
}
extension CanonicalVersion:HyperTextOutputStreamable
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

        if  case .global = self.target
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
