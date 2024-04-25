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
        var diagnostics:Diagnostics<SSGC.Symbolicator>

        private
        let codelinks:CodelinkResolver<Int32>
        private
        let doclinks:DoclinkResolver
        private
        let anchors:AnchorResolver

        init(
            diagnostics:consuming Diagnostics<SSGC.Symbolicator>,
            codelinks:CodelinkResolver<Int32>,
            doclinks:DoclinkResolver,
            anchors:AnchorResolver)
        {
            self.diagnostics = diagnostics

            self.codelinks = codelinks
            self.doclinks = doclinks
            self.anchors = anchors
        }
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
        let codelink:Codelink = .init(renamed)
        else
        {
            self.diagnostics[location] = SSGC.RenameParsingError.init(
                redirect: redirect,
                target: renamed)
            return nil
        }

        switch self.codelinks.resolve(codelink)
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
                target: codelink)
            return nil
        }
    }

    mutating
    func outline(_ codelink:Codelink,
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
            self.diagnostics[source] = CodelinkResolutionError<SSGC.Symbolicator>.init(
                overloads: overloads,
                codelink: codelink)

            return nil
        }
    }
    mutating
    func outline(_ doclink:Doclink,
        at source:SourceReference<Markdown.Source>) -> SymbolGraph.Outline?
    {
        guard
        let last:String = doclink.path.last,
        let id:Int32 = self.doclinks.resolve(doclink, docc: true)
        else
        {
            return nil
        }

        let fragment:Substring?
        if  let spelling:String = doclink.fragment
        {
            switch self.anchors[id][normalizing: spelling]
            {
            case .success(let original):
                fragment = original[...]

            case .failure(let error):
                self.diagnostics[source] = error
                fragment = nil
            }
        }
        else
        {
            fragment = nil
        }

        return .vertex(id, text: .init(path: last[...], fragment: fragment))
    }
}
