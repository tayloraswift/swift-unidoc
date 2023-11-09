import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import ModuleGraphs
import Sources
import SymbolGraphs
import UnidocDiagnostics

struct StaticResolver
{
    private
    let codelinks:CodelinkResolver<Int32>
    private
    let doclinks:DoclinkResolver

    var errors:[any StaticLinkerError]

    init(codelinks:CodelinkResolver<Int32>, doclinks:DoclinkResolver)
    {
        self.codelinks = codelinks
        self.doclinks = doclinks
        self.errors = []
    }
}
extension StaticResolver
{
    mutating
    func outline(expression:String,
        as doclink:Doclink,
        in sources:[MarkdownSource],
        at source:SourceReference<Int>?) -> SymbolGraph.Outline?
    {
        self.doclinks.resolve(doclink).map
        {
            .scalar($0, text: doclink.path.last ?? "")
        }
    }
    mutating
    func outline(expression:String,
        as codelink:Codelink,
        in sources:[MarkdownSource],
        at source:SourceReference<Int>?) -> SymbolGraph.Outline?
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
                self.errors.append(InvalidCodelinkError<Int32>.init(
                    overloads: overloads,
                    codelink: codelink,
                    context: source.map { .init(of: $0, in: sources) }))
            }
            return nil
        }
    }
}
