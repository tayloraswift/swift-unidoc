import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import LexicalPaths
import MarkdownAST
import Sources
import SymbolGraphs
import SourceDiagnostics

extension SSGC
{
    struct OutlineResolver:~Copyable
    {
        var diagnostics:Diagnostics<SSGC.Symbolicator>

        private
        let codelinks:CodelinkResolver<Int32>
        private
        let doclinks:DoclinkResolver

        init(
            diagnostics:consuming Diagnostics<SSGC.Symbolicator>,
            codelinks:CodelinkResolver<Int32>,
            doclinks:DoclinkResolver)
        {
            self.diagnostics = diagnostics

            self.codelinks = codelinks
            self.doclinks = doclinks
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
            let text:String = codelink.path.visible.joined(separator: " ")
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
        at _:SourceReference<Markdown.Source>) -> SymbolGraph.Outline?
    {
        self.doclinks.resolve(doclink, docc: true).map
        {
            .vertex($0, text: doclink.path.last ?? "")
        }
    }
}
