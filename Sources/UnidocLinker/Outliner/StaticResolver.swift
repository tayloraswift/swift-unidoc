import CodelinkResolution
import Codelinks
import DoclinkResolution
import Doclinks
import ModuleGraphs
import Sources
import SymbolGraphs

struct StaticResolver
{
    var diagnostics:[StaticDiagnostic]

    private
    let codelinks:CodelinkResolver<Int32>
    private
    let doclinks:DoclinkResolver
    /// The implicit scope that will be used to resolve doclinks.
    private
    let culture:ModuleIdentifier
    /// The implicit scope that will be used to resolve codelinks.
    private
    let scope:[String]

    init(codelinks:CodelinkResolver<Int32>,
        doclinks:DoclinkResolver,
        culture:ModuleIdentifier,
        scope:[String])
    {
        self.diagnostics = []

        self.codelinks = codelinks
        self.doclinks = doclinks
        self.culture = culture
        self.scope = scope
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
        if  let scalar:Int32 = self.doclinks.query(ascending: .documentation(self.culture),
                link: doclink)
        {
            return .scalar(scalar)
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
            return .unresolved(expression)
        }
    }
    mutating
    func outline(expression:String,
        as codelink:Codelink,
        in sources:[MarkdownSource],
        at source:SourceText<Int>?) -> SymbolGraph.Referent?
    {
        switch self.codelinks.query(ascending: self.scope, link: codelink)
        {
        case .one(let overload):
            switch overload.target
            {
            case .scalar(let address):
                return .scalar(address)

            case .vector(let address, self: let heir):
                return .vector(address, self: heir)
            }

        case .some(let overloads):
            if  overloads.isEmpty
            {
                print("DEBUG: autolink '\(expression)' will be resolved dynamically")
                return .unresolved(expression)
            }
            else
            {
                self.diagnostics.append(.init(.ambiguousCodelink(codelink, overloads),
                    context: source.map { .init(of: $0, in: sources) }))
                return nil
            }
        }
    }
}
