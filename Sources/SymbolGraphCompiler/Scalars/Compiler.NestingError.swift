extension Compiler
{
    public
    enum NestingError:Equatable, Error, Sendable
    {
        case conflict(with:UnifiedSymbolResolution)
        case phylum(SymbolGraph.Scalar.Phylum)
    }
}
extension Compiler.NestingError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .conflict(with: let symbol):
            return "Scalar is already nested within '\(symbol)'."
        
        case .phylum(let phylum):
            return "Scalar of phylum '\(phylum)' cannot be lexically nested."
        }
    }
}
