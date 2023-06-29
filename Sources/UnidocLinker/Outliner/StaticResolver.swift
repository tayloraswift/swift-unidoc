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
        at source:SourceText<Int>?) -> SymbolGraph.Referent?
    {
        if  let scalar:Int32 = self.doclinks.resolve(doclink)
        {
            return .scalar(.init(scalar, length: UInt32.init(doclink.path.count)))
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
            return .unresolved(.init(expression,
                location: source?.start.translated(through: sources)))
        }
    }
    mutating
    func outline(expression:String,
        as codelink:Codelink,
        in sources:[MarkdownSource],
        at source:SourceText<Int>?) -> SymbolGraph.Referent?
    {
        switch self.codelinks.resolve(codelink)
        {
        case .one(let overload):
            let length:UInt32 = .init(codelink.path.components.count)
            switch overload.target
            {
            case .scalar(let address):
                return .scalar(.init(address, length: length))

            case .vector(let address, self: let heir):
                return .vector(.init(address, self: heir, length: length))
            }

        case .some(let overloads):
            if  overloads.isEmpty
            {
                print("DEBUG: autolink '\(expression)' will be resolved dynamically")
                return .unresolved(.init(expression,
                    location: source?.start.translated(through: sources)))
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
