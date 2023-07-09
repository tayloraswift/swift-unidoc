import ModuleGraphs

extension Artifacts
{
    public
    enum CultureError:Error, Equatable, Sendable
    {
        case empty(ModuleIdentifier)
    }
}
extension Artifacts.CultureError:CustomStringConvertible
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
