import SymbolDescriptions

extension Compiler
{
    struct ExtendedTypes
    {
        private
        var extendees:[BlockSymbolResolution: ScalarSymbolResolution]

        private 
        init(extendees:[BlockSymbolResolution: ScalarSymbolResolution] = [:])
        {
            self.extendees = extendees
        }
    }
}
extension Compiler.ExtendedTypes
{
    func extendee(of block:BlockSymbolResolution) throws -> ScalarSymbolResolution
    {
        if let type:ScalarSymbolResolution = extendees[block]
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
    init(indexing colony:__shared SymbolColony) throws
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
