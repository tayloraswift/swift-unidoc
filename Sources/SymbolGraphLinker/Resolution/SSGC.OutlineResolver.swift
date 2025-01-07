import LexicalPaths
import LinkResolution
import MarkdownAST
import SourceDiagnostics
import Sources
import SymbolGraphs
import Symbols
import UCF

extension SSGC
{
    //  https://github.com/apple/swift/issues/71606
    struct OutlineResolver//:~Copyable
    {
        private
        let scopes:OutlineResolverEnvironment
        var tables:Linker.Tables

        init(scopes:OutlineResolverEnvironment, tables:consuming Linker.Tables)
        {
            self.scopes = scopes
            self.tables = tables
        }
    }
}
extension SSGC.OutlineResolver
{
    var diagnostics:Diagnostics<SSGC.Symbolicator>
    {
        _read   { yield  self.tables.diagnostics }
        _modify { yield &self.tables.diagnostics }
    }
}
extension SSGC.OutlineResolver
{
    var resources:[String: SSGC.Resource] { self.scopes.resources }

    private
    var origin:Int32? { self.scopes.origin }

    private
    var codelinks:UCF.ProjectWideResolver
    {
        .init(scope: self.scopes.codelink,
            global: self.tables.packageLinks,
            causal: self.scopes.causalLinks)
    }

    private
    var doclinks:UCF.ArticleResolver
    {
        .init(table: self.tables.articleLinks, scope: self.scopes.doclink)
    }
}
extension SSGC.OutlineResolver
{
    func locate(resource name:String) -> SSGC.Resource?
    {
        if  let resource:SSGC.Resource = self.resources[name]
        {
            return resource
        }

        if  let dot:String.Index = name.lastIndex(of: ".")
        {
            //  We can only fuzz file names for image resources!
            switch name[name.index(after: dot)...]
            {
            case "gif":     break
            case "jpg":     break
            case "jpeg":    break
            case "png":     break
            case "svg":     break
            case "webp":    break
            default:        return nil
            }

            return self.resources["\(name[..<dot])@2x\(name[dot...])"]
                ?? self.resources["\(name[..<dot])~dark\(name[dot...])"]
                ?? self.resources["\(name[..<dot])~dark@2x\(name[dot...])"]
        }
        for guess:String in ["svg", "webp", "png", "jpg", "jpeg", "gif"]
        {
            if  let resource:SSGC.Resource = self.resources["\(name).\(guess)"]
                ?? self.resources["\(name)@2x.\(guess)"]
                ?? self.resources["\(name)~dark.\(guess)"]
                ?? self.resources["\(name)~dark@2x.\(guess)"]
            {
                return resource
            }
        }

        return nil
    }
}
extension SSGC.OutlineResolver
{
    mutating
    func resolve(rename renamed:String,
        of redirect:UnqualifiedPath,
        at location:SourceLocation<Int32>?) -> Int32?
    {
        guard
        let selector:UCF.Selector = .init(renamed)
        else
        {
            self.diagnostics[location] = SSGC.RenameParsingError.init(
                redirect: redirect,
                target: renamed)
            return nil
        }

        switch self.codelinks.resolve(selector)
        {
        case .overload(let overload as UCF.PackageOverload):
            //  For renames, we do not distinguish between members and features.
            return overload.decl

        case .overload(let overload as UCF.CausalOverload):
            //  This rename points to a symbol is a package dependency.
            return self.tables.intern(overload.id)

        case .ambiguous(let overloads, rejected: _):
            self.diagnostics[location] = SSGC.RenameTargetError.init(
                overloads: overloads,
                redirect: redirect,
                target: selector)
            return nil

        default:
            self.diagnostics[location] = SSGC.RenameTargetError.init(
                overloads: [],
                redirect: redirect,
                target: selector)
            return nil
        }
    }

    mutating
    func translate(url:Markdown.SourceURL) -> SymbolGraph.Outline?
    {
        guard
        let translatable:UCF.Selector = url.translatableSelector
        else
        {
            return nil
        }

        switch self.scopes.causalURLs.resolve(qualified: translatable)
        {
        case .module(let module):
            //  Unidoc linker doesn’t currently support `symbol` outlines that are not
            //  declarations, so for now we just synthesize a normal vertex outline.
            let text:SymbolGraph.OutlineText = .init(path: "\(module)", fragment: nil)
            return .vertex(self.tables.intern(module) * .module, text: text)

        case .overload(let overload):
            return .symbol(self.tables.intern(overload.id))

        case .ambiguous(let overloads, rejected: let rejected):
            if  overloads.isEmpty
            {
                return nil
            }

            self.diagnostics[url.suffix.source] = UCF.ResolutionError<SSGC.Symbolicator>.init(
                overloads: overloads,
                rejected: rejected,
                selector: translatable)

            return nil
        }
    }

    mutating
    func outline(_ codelink:UCF.Selector,
        at source:SourceReference<Markdown.Source>) -> SymbolGraph.Outline?
    {
        guard
        let target:(Int32, Int32?) = self.target(of: codelink, at: source)
        else
        {
            return nil
        }

        let text:SymbolGraph.OutlineText = .init(vector: codelink.path.visible, fragment: nil)

        switch target
        {
        case (let decl, let heir?): return .vector(decl, self: heir, text: text)
        case (let decl, nil):       return .vertex(decl, text: text)
        }
    }

    mutating
    func outline(_ doclink:Doclink,
        at source:SourceReference<Markdown.Source>,
        as provenance:Markdown.SourceURL.Provenance) -> SymbolGraph.Outline?
    {
        let page:Int32

        if  doclink.path.isEmpty
        {
            guard
            let origin:Int32 = self.origin
            else
            {
                self.diagnostics[source] = .warning("""
                    same-page links are only valid within documentation that generates \
                    browsable pages
                    """)
                return nil
            }

            page = origin
        }
        else if
            let article:Int32 = self.doclinks.resolve(doclink, docc: true)
        {
            //  Doclink points to an article. Great!
            page = article
        }
        else
        {
            if  doclink.absolute
            {
                self.diagnostics[source] = SSGC.OutlineDiagnostic.unresolvedAbsolute(doclink)
                return nil
            }
            //  Resolution might still succeed by reinterpreting the doclink as a codelink.
            guard
            let codelink:UCF.Selector = .init(doclink.page)
            else
            {
                self.diagnostics[source] = SSGC.OutlineDiagnostic.unresolvedRelative(doclink)
                return nil
            }
            guard
            let target:(Int32, Int32?) = self.target(of: codelink, at: source)
            else
            {
                //  Diagnostics were already generated by ``target(of:at:)``
                return nil
            }

            if  case nil = doclink.fragment,
                case .autolink = provenance
            {
                //  Only emit this diagnostic if the suggested replacement would not lose
                //  information!
                self.diagnostics[source] = SSGC.OutlineDiagnostic.suggestReformat(doclink,
                    to: codelink)
            }

            //  Doclinks can never display more than one path component, so the second component
            //  of the target is never meaningful.
            page = target.0
        }

        let fragment:String?
        if  let spelling:String = doclink.fragment
        {
            switch self.tables.anchors[page][normalizing: spelling]
            {
            case .success(let original):
                fragment = original

            case .failure(let error):
                self.diagnostics[source] = error
                fragment = nil
            }
        }
        else
        {
            fragment = nil
        }

        if  case page? = self.origin,
            let fragment:String
        {
            return .fragment(fragment)
        }
        else if
            let last:String = doclink.path.last
        {
            return .vertex(page, text: .init(path: last[...], fragment: fragment?[...]))
        }
        else
        {
            return nil
        }
    }
}
extension SSGC.OutlineResolver
{
    private mutating
    func target(of codelink:UCF.Selector,
        at source:SourceReference<Markdown.Source>) -> (Int32, Int32?)?
    {
        let chosen:any UCF.ResolvableOverload

        switch self.codelinks.resolve(codelink)
        {
        case .module(let module):
            return (self.tables.intern(module) * .module, nil)

        case .overload(let overload as UCF.PackageOverload):
            return (overload.decl, overload.heir)

        case .overload(let overload):
            chosen = overload

        case .ambiguous(let overloads, rejected: let rejected):
            guard overloads.isEmpty, rejected.count == 1
            else
            {
                self.diagnostics[source] = UCF.ResolutionError<SSGC.Symbolicator>.init(
                    overloads: overloads,
                    rejected: rejected,
                    selector: codelink)
                return nil
            }

            chosen = rejected[0]

            self.diagnostics[source] = SSGC.OutlineDiagnostic.annealedIncorrectHash(
                in: codelink,
                to: chosen.traits.hash)
        }

        let decl:Int32 = self.tables.intern(chosen.id)

        if  case let chosen as UCF.CausalOverload = chosen,
            let heir:Symbol.Decl = chosen.heir
        {
            return (decl, self.tables.intern(heir))
        }
        else
        {
            return (decl, nil)
        }
    }
}
