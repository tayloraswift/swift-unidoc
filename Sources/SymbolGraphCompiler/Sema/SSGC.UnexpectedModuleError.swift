import SymbolGraphParts
import Symbols

extension SSGC
{
    public
    enum UnexpectedModuleError:Error, Equatable, Sendable
    {
        case culture(Symbol.Module, in:SymbolGraphPart.ID)
    }
}
extension SSGC.UnexpectedModuleError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .culture(let culture, in: let part):
            "Symbols in \(part) actually belong to culture '\(culture)'."
        }
    }
}
