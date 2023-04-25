extension Compiler.Scalars
{
    @frozen public
    struct External
    {
        @usableFromInline internal
        let nominations:[Symbol.Scalar: Compiler.ScalarNomination]

        init(_ nominations:[Symbol.Scalar: Compiler.ScalarNomination])
        {
            self.nominations = nominations
        }
    }
}
extension Compiler.Scalars.External
{
    @inlinable public
    subscript(feature scalar:Symbol.Scalar) -> (name:String, phylum:ScalarPhylum)?
    {
        switch self.nominations[scalar]
        {
        case .feature(let name, let phylum)?:   return (name, phylum)
        case .heir?, nil:                       return nil
        }
    }
    @inlinable public
    subscript(heir scalar:Symbol.Scalar) -> [String]?
    {
        switch self.nominations[scalar]
        {
        case .feature?, nil:    return nil
        case .heir(let path)?:  return path
        }
    }
}
