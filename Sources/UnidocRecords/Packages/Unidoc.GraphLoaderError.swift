import Symbols

extension Unidoc
{
    @frozen public
    enum GraphLoaderError:Error, Sendable
    {
        case unavailable(Symbol.Package)
    }
}
