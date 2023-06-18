import CodelinkResolution
import Codelinks
import Doclinks

extension StaticLinker.Diagnostic
{
    enum Problem
    {
        case ambiguousCodelink(Codelink, [Overload<Int32>])
        case invalidCodelink(String)
        case invalidDoclink(String)
        case unresolvedDoclink(Doclink)
    }
}
