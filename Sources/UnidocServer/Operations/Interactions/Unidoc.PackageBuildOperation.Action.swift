import Symbols

extension Unidoc.PackageBuildOperation
{
    enum Action
    {
        case submitSymbolic(Symbol.Edition)
        case submit(Unidoc.Package, Unidoc.BuildRequest<Void>)
        case cancel(Unidoc.Package)
        case cancelSymbolic(Symbol.Package)
    }
}
