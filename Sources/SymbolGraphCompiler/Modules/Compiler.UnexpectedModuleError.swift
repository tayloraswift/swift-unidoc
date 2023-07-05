import ModuleGraphs
import SymbolGraphParts

extension Compiler
{
    public
    enum UnexpectedModuleError:Error, Equatable, Sendable
    {
        case culture(ModuleIdentifier, in:SymbolGraphPart.ID)
    }
}
extension Compiler.UnexpectedModuleError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .culture(let culture, in: let part):
            return "Symbols in \(part) actually belong to culture '\(culture)'."
        }
    }
}
