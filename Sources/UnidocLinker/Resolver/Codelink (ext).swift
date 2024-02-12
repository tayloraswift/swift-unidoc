import Codelinks
import Doclinks
import SymbolGraphs

extension Codelink
{
    init?(parsing unresolved:borrowing SymbolGraph.Outline.Unresolved)
    {
        switch unresolved.type
        {
        case .doc:
            guard
            let doclink:Doclink = .init(unresolved.link)
            else
            {
                return nil
            }

            self.init(doclink.path.joined(separator: "/"))

        case .ucf:
            self.init(unresolved.link)

        case .unidocV3:
            guard
            let unidocV3:CodelinkV3 = .init(unresolved.link)
            else
            {
                return nil
            }

            self.init(v3: unidocV3)
        }
    }
}
