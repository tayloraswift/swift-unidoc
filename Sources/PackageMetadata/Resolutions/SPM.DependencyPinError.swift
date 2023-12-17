import Symbols

extension SPM
{
    @frozen public
    enum DependencyPinError:Error, Equatable, Sendable
    {
        case duplicate(Symbol.Package)
        case undefined(Symbol.Package)
    }
}
