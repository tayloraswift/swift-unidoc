import LexicalPaths
import LinkResolution
import MarkdownAST
import Sources
import SymbolGraphs
import SourceDiagnostics
import UCF

extension SSGC
{
    struct OutlineResolver:~Copyable
    {
        private
        let scopes:OutlineResolutionScopes
        var tables:Linker.Tables

        init(scopes:OutlineResolutionScopes, tables:consuming Linker.Tables)
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
    var codelinks:UCF.Overload<Int32>.Resolver
    {
        .init(table: self.tables.codelinks, scope: self.scopes.codelink)
    }

    private
    var doclinks:DoclinkResolver
    {
        .init(table: self.tables.doclinks, scope: self.scopes.doclink)
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
        case .one(let overload):
            return switch overload.target
            {
            case .scalar(let id):           id
            case .vector(let id, self: _):  id
            }

        case .some(let overloads):
            self.diagnostics[location] = SSGC.RenameTargetError.init(
                overloads: overloads,
                redirect: redirect,
                target: selector)
            return nil
        }
    }

    mutating
    func outline(_ codelink:UCF.Selector,
        at source:SourceReference<Markdown.Source>) -> SymbolGraph.Outline?
    {
        switch self.codelinks.resolve(codelink)
        {
        case .some([]):
            return nil

        case .one(let overload):
            let text:SymbolGraph.OutlineText = .init(vector: codelink.path.visible,
                fragment: nil)

            switch overload.target
            {
            case .scalar(let id):
                return .vertex(id, text: text)

            case .vector(let id, self: let heir):
                return .vector(id, self: heir, text: text)
            }

        case .some(let overloads):
            self.diagnostics[source] = UCF.OverloadResolutionError<SSGC.Symbolicator>.init(
                overloads: overloads,
                selector: codelink)

            return nil
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
