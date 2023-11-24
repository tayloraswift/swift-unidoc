import Symbols

extension Compiler
{
    public
    enum DuplicateModuleError:Equatable, Error, Sendable
    {
        case culture(Symbol.Module)
    }
}
extension Compiler.DuplicateModuleError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .culture(let module):
            return "Duplicate culture '\(module)'."
        }
    }
}
