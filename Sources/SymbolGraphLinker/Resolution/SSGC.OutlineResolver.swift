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
        let codelinks:UCF.Overload<Int32>.Resolver
        private
        let doclinks:DoclinkResolver
        private
        let origin:Int32?

        var tables:Linker.Tables

        init(
            codelinks:UCF.Overload<Int32>.Resolver,
            doclinks:DoclinkResolver,
            origin:Int32?,
            tables:consuming Linker.Tables)
        {
            self.codelinks = codelinks
            self.doclinks = doclinks
            self.origin = origin

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
