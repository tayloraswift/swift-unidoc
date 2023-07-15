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
        at source:SourceText<Int>?) -> SymbolGraph.Outline?
    {
        if  let scalar:Int32 = self.doclinks.resolve(doclink)
        {
            return .init(referent: .scalar(scalar), text: doclink.path.last ?? "")
        }
        //  Resolution might still succeed by reinterpreting the doclink as a codelink.
        if !doclink.absolute,
            let codelink:Codelink = .init(doclink.path.joined(separator: "/"))
        {
            return self.outline(expression: expression,
                as: codelink,
                in: sources,
                at: source)
        }
        else
        {
            print("DEBUG: doclink '\(expression)' will be resolved dynamically")
            return .init(
                referent: .unresolved(source?.start.translated(through: sources)),
                text: expression)
        }
    }
    mutating
    func outline(expression:String,
        as codelink:Codelink,
        in sources:[MarkdownSource],
        at source:SourceText<Int>?) -> SymbolGraph.Outline?
    {
        switch self.codelinks.resolve(codelink)
        {
        case .one(let overload):
            let text:String = codelink.path.components.joined(separator: " ")
            switch overload.target
            {
            case .scalar(let address):
                return .init(
                    referent: .scalar(address),
                    text: text)

            case .vector(let address, self: let heir):
                return .init(
                    referent: .vector(address, self: heir),
                    text: text)
            }

        case .some(let overloads):
            if  overloads.isEmpty
            {
                print("DEBUG: autolink '\(expression)' will be resolved dynamically")
                return .init(
                    referent: .unresolved(source?.start.translated(through: sources)),
                    text: expression)
            }
            else
            {
                self.errors.append(InvalidCodelinkError<Int32>.init(
                    overloads: overloads,
                    codelink: codelink,
                    context: source.map { .init(of: $0, in: sources) }))
                return nil
            }
        }
    }
}
