import SymbolDescriptions

extension Compiler
{
    @frozen public
    enum PhylumError:Equatable, Error
    {
        case unsupported(SymbolDescription.Phylum)
        //case invalid(SymbolDescription.Phylum, of:ScalarSymbolResolution)
    }
}
extension Compiler.PhylumError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .unsupported(let phylum):
            return "Unsupported phylum '\(phylum)'."
        //case .invalid(let phylum, of: let resolution):
        //    return "Invalid phylum '\(phylum)' (of scalar '\(resolution)')."
        }
    }
}
