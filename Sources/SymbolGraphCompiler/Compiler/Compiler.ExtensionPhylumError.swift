extension Compiler
{
    @frozen public
    enum ExtensionPhylumError:Equatable, Error
    {
        case unsupported(SymbolPhylum)
    }
}
extension Compiler.ExtensionPhylumError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .unsupported(let phylum): return "Unsupported phylum '\(phylum)'."
        }
    }
}
