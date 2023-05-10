import Symbols
import SymbolGraphParts

extension Compiler
{
    struct ExtendedTypes
    {
        private
        var extendees:[BlockSymbol: ScalarSymbol]

        private
        init(extendees:[BlockSymbol: ScalarSymbol] = [:])
        {
            self.extendees = extendees
        }
    }
}
extension Compiler.ExtendedTypes
{
    func extendee(of block:BlockSymbol) throws -> ScalarSymbol
    {
        if let type:ScalarSymbol = extendees[block]
        {
            return type
        }
        else
        {
            throw Compiler.UnclaimedBlockError.init(unclaimed: block)
        }
    }
}
extension Compiler.ExtendedTypes
{
    init(indexing colony:__shared SymbolGraphPart) throws
    {
        self.init()

        for relationship:SymbolRelationship in colony.relationships
        {
            guard case .extension(let relationship) = relationship
            else
            {
                continue
            }
            guard case nil = self.extendees.updateValue(relationship.target,
                    forKey: relationship.source)
            else
            {
                throw Compiler.DuplicateSymbolError.block(relationship.source)
            }
        }
    }
}
