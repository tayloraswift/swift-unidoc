import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import ModuleGraphs
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
        self.diagnostics = .init()

        self.codelinks = codelinks
        self.doclinks = doclinks
    }
}
extension StaticResolver
{
    mutating
    func outline(_ autolink:Autolink, as codelink:Codelink) -> SymbolGraph.Outline?
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
    func outline(_ autolink:Autolink, as doclink:Doclink) -> SymbolGraph.Outline?
    {
        self.doclinks.resolve(doclink).map
        {
            .scalar($0, text: doclink.path.last ?? "")
        }
    }
}
