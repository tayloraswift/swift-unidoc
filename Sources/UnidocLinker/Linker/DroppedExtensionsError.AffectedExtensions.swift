import ModuleGraphs
import Symbols

extension DroppedExtensionsError
{
    @frozen public
    enum AffectedExtensions:Equatable, Sendable
    {
        case decl(Symbol.Decl)
        case namespace(ModuleIdentifier)
    }
}
