import SymbolGraphParts

extension SymbolRelationship
{
    func `do`(_ body:(Self) throws -> Void) rethrows
    {
        do
        {
            try body(self)
        }
        catch let error
        {
            throw SSGC.EdgeError<Self>.init(underlying: error, in: self)
        }
    }
}
