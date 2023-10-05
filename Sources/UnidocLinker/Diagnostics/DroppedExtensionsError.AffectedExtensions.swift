import ModuleGraphs
import Symbols

extension DroppedExtensionsError
{
    @frozen public
    enum AffectedExtensions:Equatable
    {
        case decl(Symbol.Decl)
        case namespace(ModuleIdentifier)
    }
}
