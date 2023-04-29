extension Compiler
{
    /// A thin wrapper around a dictionary of ``ScalarNomination``s.
    @frozen public
    struct ScalarNominations:Sendable
    {
        @usableFromInline internal
        let nominations:[Symbol.Scalar: Compiler.ScalarNomination]

        init(_ nominations:[Symbol.Scalar: Compiler.ScalarNomination])
        {
            self.nominations = nominations
        }
    }
}
extension Compiler.ScalarNominations
{
    @inlinable public
    subscript(feature scalar:Symbol.Scalar) -> (name:String, phylum:ScalarPhylum)?
    {
        self.nominations[scalar].map { ($0.name, $0.phylum) }
    }
}
