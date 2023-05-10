import Repositories

extension Driver
{
    public
    enum CultureError:Error, Equatable, Sendable
    {
        case empty(ModuleIdentifier)
    }
}
extension Driver.CultureError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .empty(let culture): return "Culture '\(culture)' has no symbol data."
        }
    }
}
