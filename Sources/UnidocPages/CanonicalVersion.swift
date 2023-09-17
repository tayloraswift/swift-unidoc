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
    init?(principal:__shared WideQuery.Output.Principal)
    {
        guard
        let names:Volume.Names = principal.namesOfLatest,
        let patch:PatchVersion = names.patch
        else
        {
            return nil
        }

        //  This can happen if you visit the latest stable release explicitly in the URL bar.
        if  principal.names.id == names.id
        {
            return nil
        }

        let relationship:Relationship
        if  let origin:PatchVersion = principal.names.patch
        {
            relationship = origin < patch ? .later : .earlier
        }
        else
        {
            relationship = .stable
        }

        let volume:URI = Site.Docs[names]
        let target:Target

        if  let master:Volume.Master = principal.masterInLatest
        {
            switch master
            {
            case .article(let master):  target = .article(Site.Docs[names, master.shoot])
            case .culture(let master):  target = .culture(Site.Docs[names, master.shoot])
            case .decl(let master):     target = .decl(Site.Docs[names, master.shoot])
            case .file:                 return   nil
            case .meta:                 target = .meta
            }
        }
        else
        {
            switch principal.master
            {
            case .article?:             target = .article(nil)
            case .culture?:             target = .culture(nil)
            case .decl?:                target = .decl(nil)
            case .file?, nil:           return   nil
            case .meta?:                target = .meta
            }
        }

        self.init(relationship: relationship,
            package: names.display ?? "\(names.package)",
            volume: volume,
            target: target)
    }

    private
    init?(relationship:Relationship,
        package:String,
        volume:URI,
        master:Volume.Master,
        in names:Volume.Names)
    {
        let target:Target

        switch master
        {
        case .article(let master):  target = .article(Site.Docs[names, master.shoot])
        case .culture(let master):  target = .culture(Site.Docs[names, master.shoot])
        case .decl(let master):     target = .decl(Site.Docs[names, master.shoot])
        case .file:                 return   nil
        case .meta:                 target = .meta
        }

        self.init(relationship: relationship, package: package, volume: volume, target: target)
    }
}
extension CanonicalVersion
{
    @inlinable internal
    var uri:URI?
    {
        switch self.target
        {
        case .article(let uri): return uri
        case .culture(let uri): return uri
        case .decl(let uri):    return uri
        case .meta:             return self.volume
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

        if  case .meta = self.target
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
