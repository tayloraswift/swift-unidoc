extension Compiler
{
    public
    enum SymbolReferenceError:Equatable, Error
    {
        case source
        case target
    }
}
