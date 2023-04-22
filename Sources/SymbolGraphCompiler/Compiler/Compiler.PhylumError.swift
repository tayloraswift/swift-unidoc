import SymbolGraphParts

extension Compiler
{
    @frozen public
    enum PhylumError:Equatable, Error
    {
        case unsupported(SymbolDescription.Phylum)
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
        }
    }
}
