import CodelinkResolution
import Codelinks
import Doclinks
import MarkdownLinking
import SourceDiagnostics
import Sources
import SymbolGraphs
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct Resolver:~Copyable
    {
        private
        let codelinks:CodelinkResolver<Scalar>
        private
        let caseless:CodelinkResolver<Scalar>
        private(set)
        var context:Linker

        init(
            codelinks:CodelinkResolver<Scalar>,
            caseless:CodelinkResolver<Scalar>,
            context:consuming Linker)
        {
            self.codelinks = codelinks
            self.caseless = caseless
            self.context = context
        }
    }
}
extension Unidoc.Resolver
{
    private
    var current:Unidoc.Linker.Graph { self.context.current }

    private
    var diagnostics:Diagnostics<Unidoc.Symbolicator>
    {
        _read   { yield  self.context.diagnostics }
        _modify { yield &self.context.diagnostics }
    }
}
extension Unidoc.Resolver
{
    mutating
    func link(article:SymbolGraph.Article) ->
    (
        overview:Unidoc.Passage?,
        details:Unidoc.Passage?
    )
    {
        let outlines:[Unidoc.Outline] = article.outlines.map { self.expand($0) }

        let overview:Unidoc.Passage? = article.overview.isEmpty ? nil : .init(
            outlines: .init(outlines[..<article.fold]),
            markdown: article.overview)
        let details:Unidoc.Passage? = article.details.isEmpty ? nil : .init(
            outlines: .init(outlines[article.fold...]),
            markdown: article.details)
        return (overview, details)
    }

    mutating
    func link(
        topic:SymbolGraph.Topic) -> (overview:Unidoc.Passage?, members:[Unidoc.TopicMember])
    {
        let overview:Unidoc.Passage? = topic.overview.isEmpty ? nil : .init(
            outlines: topic.outlines.map { self.expand($0) },
            markdown: topic.overview)

        return (overview, topic.members.map { self.resolve($0) })
    }
}
extension Unidoc.Resolver
{
    private mutating
    func expand(_ outline:SymbolGraph.Outline) -> Unidoc.Outline
    {
        func words(in text:String) -> Int
        {
            var length:Int = 1
            for character:Character in text where character == " "
            {
                length += 1
            }
            return length
        }

        switch outline
        {
        case    .vertex(let id, text: let text):
            if      let _:Int = id / .decl,
                    let id:Unidoc.Scalar = self.current.scalars.decls[id]
            {
                return .path(text, self.context.expand(id, to: words(in: text)))
            }
            else if let namespace:Int = id / .module,
                    let id:Unidoc.Scalar = self.current.scalars.modules[namespace]
            {
                return .path(text, [id])
            }
            else
            {
                return .path(text, [self.current.id + id])
            }

        case    .vector(let feature, self: let heir, text: let text):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature],
                let heir:Unidoc.Scalar = self.current.scalars.decls[heir]
            {
                return .path(text, self.context.expand((heir, feature), to: words(in: text)))
            }

        case    .unresolved(let unresolved):
            let resolution:CodelinkResolver<Unidoc.Scalar>.Overload.Target?
            let codelink:Codelink

            resolution:
            if  case .web = unresolved.type
            {
                let domain:Substring = unresolved.link.prefix { $0 != "/" }

                if  let link:Codelink = .init(translating: unresolved.link, to: domain)
                {
                    codelink = link
                }
                else
                {
                    let root:Substring
                    if  let j:String.Index = domain.lastIndex(of: "."),
                        let i:String.Index = domain[..<j].lastIndex(of: ".")
                    {
                        root = domain[domain.index(after: i)...]
                    }
                    else
                    {
                        root = domain
                    }
                    //  We will follow links to GitHub and reputable open-source indexes.
                    let safe:Bool = switch root
                    {
                    case "freebsd.org":     true
                    case "github.com":      true
                    case "ietf.org":        true
                    case "man7.org":        true
                    case "mozilla.org":     true
                    case "scala-lang.org":  true
                    case "swiftinit.org":   true
                    case "swift.org":       true
                    case "wikipedia.org":   true
                    default:                false
                    }

                    return .link(https: unresolved.link, safe: safe)
                }

                //  Translation always lowercases the URL, so we need to use the collated table.
                switch self.caseless.resolve(codelink)
                {
                case .some(let overloads):
                    guard
                    let overload:CodelinkResolver<Unidoc.Scalar>.Overload = overloads.first
                    else
                    {
                        //  Not an error, this was only speculative.
                        return .link(https: unresolved.link, safe: false)
                    }

                    resolution = overload.target

                case .one(let overload):
                    resolution = overload.target
                }

                print("DEBUG: successful translation of '\(unresolved.link)'")
            }
            else if
                let resolved:(Codelink, CodelinkResolver<Unidoc.Scalar>.Overload.Target?) =
                    self.resolve(unresolved)
            {
                (codelink, resolution) = resolved
            }
            else
            {
                return .text(unresolved.link)
            }

            /// This looks a lot like a stem, but it always uses spaces, never tabs.
            /// Its purpose is to allow splitting the path into words without parsing the
            /// Swift language grammar.
            var path:String { codelink.path.visible.joined(separator: " ") }
            var text:String { codelink.path.visible.joined(separator: ".") }
            let length:Int = codelink.path.visible.count

            switch resolution
            {
            case nil:
                return .text(text)

            case .scalar(let scalar)?:
                return .path(path, self.context.expand(scalar, to: length))

            case .vector(let feature, self: let heir)?:
                return .path(path, self.context.expand((heir, feature), to: length))
            }
        }

        return .text("<unavailable>")
    }

    private mutating
    func resolve(_ outline:SymbolGraph.Outline) -> Unidoc.TopicMember
    {
        switch outline
        {
        case   .vertex(let scalar, text: _):
            if      let _:Int = scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.scalars.decls[scalar]
            {
                return .scalar(scalar)
            }
            else if let namespace:Int = scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.scalars.modules[namespace]
            {
                return .scalar(scalar)
            }
            else
            {
                //  The rest of the planes don’t cross packages... yet...
                return .scalar(self.current.id + scalar)
            }

        case    .vector(let feature, self: _, text: _):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature]
            {
                return .scalar(feature)
            }

        case    .unresolved(let unresolved):
            switch self.resolve(unresolved)
            {
            case  nil:
                return .text(unresolved.link)

            case (let codelink, nil)?:
                return .text(codelink.path.visible.joined(separator: "."))

            case (_, .scalar(let scalar)?)?:
                return .scalar(scalar)

            case (_, .vector(let feature, self: _)?)?:
                return .scalar(feature)
            }
        }

        return .text("<unavailable>")
    }

    private mutating
    func resolve(_ unresolved:SymbolGraph.Outline.Unresolved) ->
    (
        codelink:Codelink,
        resolved:CodelinkResolver<Unidoc.Scalar>.Overload.Target?
    )?
    {
        let location:SourceLocation<Unidoc.Scalar>? = unresolved.location?.map
        {
            self.current.id + $0
        }

        guard
        let codelink:Codelink = .init(parsing: unresolved)
        else
        {
            //  Somehow, a symbolgraph was compiled with an unparseable codelink!
            self.diagnostics[location] = InvalidAutolinkError<Unidoc.Symbolicator>.init(
                string: unresolved.link)

            return nil
        }

        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.diagnostics[location] = InvalidCodelinkError<Unidoc.Symbolicator>.init(
                overloads: overloads,
                codelink: codelink)

            return (codelink, nil)

        case .one(let overload):
            return (codelink, overload.target)
        }
    }
}
