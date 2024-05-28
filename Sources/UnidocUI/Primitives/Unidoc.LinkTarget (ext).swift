import URI

extension Unidoc.LinkTarget
{
    mutating
    func export()
    {
        if  case .location(let uri) = self
        {
            self = .exported(uri)
        }
    }

    mutating
    func export(as article:Unidoc.ArticleVertex, base principal:Unidoc.AnyVertex)
    {
        if  let link:Self = .relative(target: article, base: principal)
        {
            self = link
        }
        else
        {
            self.export()
        }
    }

    /// Returns a link to the `target` article relative to the `principal` vertex, if one could
    /// be constructed.
    ///
    /// We only perform this transformation if both vertices are articles in the same volume,
    /// because we know article paths are at most one component deep.
    static
    func relative(target article:Unidoc.ArticleVertex, base principal:Unidoc.AnyVertex) -> Self?
    {
        guard case .article(let principal) = principal,
        case article.id.edition = principal.id.edition
        else
        {
            //  Articles do not belong to the same volume.
            return nil
        }

        if  article.stem.first == principal.stem.first
        {
            //  Both articles are within the same module.
            return .location("../\(URI.Path.Component.push(article.stem.last.lowercased()))")
        }
        else
        {
            var uri:URI.Path = [.pop, .pop]
                uri += article.stem
            return .location("\(uri)")
        }
    }
}
