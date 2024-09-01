import SymbolGraphParts

extension SymbolRelationship
{
    func `do`<T>(_ body:(Self) throws -> T) rethrows -> T
    {
        do
        {
            return try body(self)
        }
        catch let error
        {
            throw SSGC.EdgeError<Self>.init(underlying: error, in: self)
        }
    }
}
