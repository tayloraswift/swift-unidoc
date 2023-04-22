import SymbolGraphParts

extension Compiler
{
    struct ExtendedTypes
    {
        private
        var extendees:[Symbol.Block: Symbol.Scalar]

        private 
        init(extendees:[Symbol.Block: Symbol.Scalar] = [:])
        {
            self.extendees = extendees
        }
    }
}
extension Compiler.ExtendedTypes
{
    func extendee(of block:Symbol.Block) throws -> Symbol.Scalar
    {
        if let type:Symbol.Scalar = extendees[block]
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
                throw Compiler.DuplicateBlockError.init()
            }
        }
    }
}
