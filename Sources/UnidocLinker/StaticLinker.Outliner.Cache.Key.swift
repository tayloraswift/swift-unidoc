import Codelinks
import Doclinks

extension StaticLinker.Outliner.Cache
{
    enum Key:Equatable, Hashable, Sendable
    {
        case codelink(Codelink)
        case doclink(Doclink)
    }
}
