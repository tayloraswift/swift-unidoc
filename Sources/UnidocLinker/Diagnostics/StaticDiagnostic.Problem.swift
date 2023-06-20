import CodelinkResolution
import Codelinks
import Doclinks

extension StaticDiagnostic
{
    enum Problem
    {
        case ambiguousCodelink(Codelink, [CodelinkResolver<Int32>.Overload])
        case invalidCodelink(String)
        case invalidDoclink(String)
        //case unresolvedDoclink(Doclink)
    }
}
