import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import LexicalPaths
import MarkdownAST
import Sources
import SymbolGraphs
import UnidocDiagnostics

struct StaticResolver:~Copyable
{
    var diagnostics:DiagnosticContext<StaticSymbolicator>

    private
    let codelinks:CodelinkResolver<Int32>
    private
    let doclinks:DoclinkResolver

    init(
        diagnostics:consuming DiagnosticContext<StaticSymbolicator>,
        codelinks:CodelinkResolver<Int32>,
        doclinks:DoclinkResolver)
    {
        self.diagnostics = diagnostics

        self.codelinks = codelinks
        self.doclinks = doclinks
    }
}
extension StaticResolver
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
            self.diagnostics[location] = StaticLinker.RenameParsingError.init(
                redirect: redirect,
                target: renamed)
            return nil
        }

        switch self.codelinks.resolve(codelink)
        {
        case .one(let overload):
            return switch overload.target
            {
            case .scalar(let address):          address
            case .vector(let address, self: _): address
            }

        case .some(let overloads):
            self.diagnostics[location] = StaticLinker.RenameTargetError.init(
                overloads: overloads,
                redirect: redirect,
                target: codelink)
            return nil
        }
    }

    mutating
    func outline(_ autolink:MarkdownInline.Autolink,
        as codelink:Codelink) -> SymbolGraph.Outline?
    {
        switch self.codelinks.resolve(codelink)
        {
        case .one(let overload):
            let text:String = codelink.path.visible.joined(separator: " ")
            switch overload.target
            {
            case .scalar(let address):
                return .scalar(address, text: text)

            case .vector(let address, self: let heir):
                return .vector(address, self: heir, text: text)
            }

        case .some(let overloads):
            if !overloads.isEmpty
            {
                self.diagnostics[autolink] = InvalidCodelinkError<StaticSymbolicator>.init(
                    overloads: overloads,
                    codelink: codelink)
            }
            return nil
        }
    }
    mutating
    func outline(_ autolink:MarkdownInline.Autolink,
        as doclink:Doclink) -> SymbolGraph.Outline?
    {
        self.doclinks.resolve(doclink).map
        {
            .scalar($0, text: doclink.path.last ?? "")
        }
    }
}
