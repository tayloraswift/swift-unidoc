import LinkResolution
import SourceDiagnostics
import Sources
import SymbolGraphs
import UCF
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
}
extension Unidoc.Resolver
{
    private mutating
    func expand(_ outline:SymbolGraph.Outline) -> Unidoc.Outline
    {
        switch outline
        {
        case .location(let location):
            //  File references never cross packages, so this is basically a no-op.
            let line:Int? = location.position == .zero ? nil : location.position.line
            return .file(line: line, self.current.id + location.file)

        case .fragment(let text):
            return .fragment(text)

        case .vertex(let id, text: let text):
            if  case SymbolGraph.Plane.decl? = .of(id),
                let id:Unidoc.Scalar = self.current.scalars.decls[id]
            {
                return .path(text, self.context.expand(id, to: text.words))
            }
            else if
                let namespace:Int = id / .module,
                let id:Unidoc.Scalar = self.current.scalars.modules[namespace]
            {
                return .path(text, [id])
            }
            else if
                case SymbolGraph.Plane.file? = .of(id)
            {
                //  Prior to v0.8.21 of the symbol graph compiler, we encoded references to
                //  files as vertex outlines. Eventually, the renderer will begin expecting
                //  file references to appear as file outlines, so we need to prepare for that.
                return .file(line: nil, self.current.id + id)
            }
            else
            {
                return .path(text, [self.current.id + id])
            }

        case .vector(let feature, self: let heir, text: let text):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature],
                let heir:Unidoc.Scalar = self.current.scalars.decls[heir]
            {
                return .path(text, self.context.expand((heir, feature), to: text.words))
            }

        case .unresolved(let unresolved):
            let location:SourceLocation<Unidoc.Scalar>? = unresolved.location?.map
            {
                self.current.id + $0
            }

            switch unresolved.type
            {
            case .web:
                return self.resolve(web: unresolved.link, at: location)

            case .doc:
                return self.resolve(doc: unresolved.link, at: location)

            case .ucf:
                return self.resolve(ucf: unresolved.link, at: location)
            }
        }

        return .fallback(text: "<unavailable>")
    }
}
extension Unidoc.Resolver
{
    private mutating
    func resolve(ucf link:String, at location:SourceLocation<Unidoc.Scalar>?) -> Unidoc.Outline
    {
        guard
        let codelink:Codelink = .init(link)
        else
        {
            //  Somehow, a symbolgraph was compiled with an unparseable codelink!
            self.diagnostics[location] = .error("""
                autolink expression '\(link)' could not be parsed
                """)
            return .fallback(text: link)
        }

        let resolution:CodelinkResolver<Unidoc.Scalar>.Overload.Target?

        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.diagnostics[location] = CodelinkResolutionError<Unidoc.Symbolicator>.init(
                overloads: overloads,
                codelink: codelink)
            resolution = nil

        case .one(let overload):
            resolution = overload.target
        }

        return self.context.format(codelink: codelink, to: resolution)
    }

    private mutating
    func resolve(doc link:String, at location:SourceLocation<Unidoc.Scalar>?) -> Unidoc.Outline
    {
        guard
        let doclink:Doclink = .init(doc: link[...])
        else
        {
            //  Somehow, a symbolgraph was compiled with an unparseable doclink!
            self.diagnostics[location] = .error("""
                doclink expression '\(link)' could not be parsed
                """)
            return .fallback(text: link)
        }

        guard
        let codelink:Codelink = .equivalent(to: doclink)
        else
        {
            //  We don’t really support cross-package doclinks yet.
            self.diagnostics[location] = .warning("""
                dynamic resolution of doclink '\(link)' is not supported yet
                """)
            return .fallback(text: link)
        }

        let resolution:CodelinkResolver<Unidoc.Scalar>.Overload.Target?

        //  TODO: improve diagnostics
        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.diagnostics[location] = CodelinkResolutionError<Unidoc.Symbolicator>.init(
                overloads: overloads,
                codelink: codelink)
            resolution = nil

        case .one(let overload):
            resolution = overload.target
        }

        return self.context.format(codelink: codelink, to: resolution)
    }

    private mutating
    func resolve(web link:String, at _:SourceLocation<Unidoc.Scalar>?) -> Unidoc.Outline
    {
        let domain:Substring = link.prefix { $0 != "/" }

        //  FIXME: codelink is probably not the right model type here. All of these paths will
        //  be slash (`/`) separated.
        guard
        let codelink:Codelink = .init(translating: link, to: domain)
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

            return .link(https: link, safe: safe)
        }

        let resolution:CodelinkResolver<Unidoc.Scalar>.Overload.Target?

        //  Translation always lowercases the URL, so we need to use the collated table.
        switch self.caseless.resolve(codelink)
        {
        case .some(let overloads):
            guard
            let overload:CodelinkResolver<Unidoc.Scalar>.Overload = overloads.first
            else
            {
                //  Not an error, this was only speculative.
                return .link(https: link, safe: false)
            }

            resolution = overload.target

        case .one(let overload):
            resolution = overload.target
        }

        print("DEBUG: successful translation of '\(link)'")

        return self.context.format(codelink: codelink, to: resolution)
    }
}
