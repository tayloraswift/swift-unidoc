import Symbols

extension Swiftinit.PackageConfigEndpoint
{
    enum Update
    {
        case hidden(Bool)
        case symbol(Symbol.Package)
    }
}
