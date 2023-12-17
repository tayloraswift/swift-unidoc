import Codelinks
import Doclinks
import Sources
import SymbolGraphs
import Unidoc
import UnidocDiagnostics

extension Unidoc.Resolver
{
    struct Autolink
    {
        let unresolved:SymbolGraph.Outline.Unresolved
        let location:SourceLocation<Unidoc.Scalar>?

        init(_ unresolved:SymbolGraph.Outline.Unresolved,
            location:SourceLocation<Unidoc.Scalar>?)
        {
            self.unresolved = unresolved
            self.location = location
        }
    }
}
extension Unidoc.Resolver.Autolink:DiagnosticSubject
{
    var context:SourceContext { .init() }
}
extension Unidoc.Resolver.Autolink
{
    var parsed:Codelink?
    {
        switch self.unresolved.type
        {
        case .doc:
            guard
            let doclink:Doclink = .init(unresolved.link)
            else
            {
                return nil
            }

            return .init(doclink.path.joined(separator: "/"))

        case .ucf:
            return .init(unresolved.link)

        case .unidocV3:
            guard
            let unidocV3:CodelinkV3 = .init(unresolved.link)
            else
            {
                return nil
            }

            return .init(v3: unidocV3)
        }
    }
}
