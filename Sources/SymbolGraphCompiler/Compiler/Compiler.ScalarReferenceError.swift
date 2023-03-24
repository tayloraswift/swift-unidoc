extension Compiler
{
    public
    enum ScalarReferenceError:Equatable, Error
    {
        case excluded(ScalarSymbolResolution)
        case external(ScalarSymbolResolution)
    }
}
