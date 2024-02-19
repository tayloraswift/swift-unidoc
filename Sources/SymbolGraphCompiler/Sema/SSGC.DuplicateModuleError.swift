import Symbols

extension SSGC
{
    public
    enum DuplicateModuleError:Equatable, Error, Sendable
    {
        case culture(Symbol.Module)
    }
}
extension SSGC.DuplicateModuleError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .culture(let module):
            "Duplicate culture '\(module)'."
        }
    }
}
