extension Compiler
{
    @frozen public
    enum ScalarPhylumError:Equatable, Error
    {
        case unsupported(SymbolPhylum)
        case invalid(SymbolPhylum, of:ScalarSymbolResolution)
    }
}
extension Compiler.ScalarPhylumError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .unsupported(let phylum):
            return "Unsupported phylum '\(phylum)'."
        case .invalid(let phylum, of: let resolution):
            return "Invalid phylum '\(phylum)' (of scalar '\(resolution)')."
        }
    }
}
