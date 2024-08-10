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
    struct OutlineResolver:~Copyable
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
    func outline(_ codelink:UCF.Selector,
        at source:SourceReference<Markdown.Source>) -> SymbolGraph.Outline?
    {
        let text:SymbolGraph.OutlineText = .init(vector: codelink.path.visible, fragment: nil)

        switch self.codelinks.resolve(codelink)
        {
        case .ambiguous(let overloads, rejected: let rejected):
            self.diagnostics[source] = UCF.ResolutionError<SSGC.Symbolicator>.init(
                overloads: overloads,
                rejected: rejected,
                selector: codelink)

            return nil

        case .overload(let overload as UCF.PackageOverload):
            if  let heir:Int32 = overload.heir
            {
                return .vector(heir, self: heir, text: text)
            }
            else
            {
                return .vertex(overload.decl, text: text)
            }

        case .overload(let overload):
            let decl:Int32 = self.tables.intern(overload.id)

            if  case let overload as UCF.CausalOverload = overload,
                let heir:Symbol.Decl = overload.heir
            {
                return .vector(decl, self: self.tables.intern(heir), text: text)
            }
            else
            {
                return .vertex(decl, text: text)
            }

        case .module(let module):
            return .vertex(self.tables.intern(module) * .module, text: text)

        }
    }

    mutating
    func outline(_ doclink:Doclink,
        at source:SourceReference<Markdown.Source>) -> SymbolGraph.Outline?
    {
        guard
        let page:Int32 = doclink.path.isEmpty ? self.origin : self.doclinks.resolve(doclink,
            docc: true)
        else
        {
            return nil
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
