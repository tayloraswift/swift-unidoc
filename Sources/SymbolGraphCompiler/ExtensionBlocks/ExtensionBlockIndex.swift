import SymbolColonies

struct ExtensionBlockIndex
{
    private
    var extendees:[ExtensionBlockResolution: UnifiedScalarResolution]

    private 
    init(extendees:[ExtensionBlockResolution: UnifiedScalarResolution] = [:])
    {
        self.extendees = extendees
    }
}
extension ExtensionBlockIndex
{
    func extendee(of block:ExtensionBlockResolution) throws -> UnifiedScalarResolution
    {
        if let type:UnifiedScalarResolution = extendees[block]
        {
            return type
        }
        else
        {
            throw ExtensionBlockUnclaimedError.init(usr: .block(block))
        }
    }
}
extension ExtensionBlockIndex
{
    init(indexing colony:__shared SymbolColony) throws
    {
        self.init()

        for relationship:SymbolRelationship in colony.relationships where
            relationship.type == .extension
        {
            switch (relationship.source, relationship.target)
            {
            case (.block(let block), .scalar(let type)):
                self.extendees[block] = type

            case (.block(let block), let type):
                //  Extension block cannot extend a compound, or another
                //  extension block.
                throw ExtensionBlockRelationshipError.target(extension: block, of: type)
            
            case (let source, let type):
                //  Extension block must have an extension block name.
                throw ExtensionBlockRelationshipError.source(extension: source, of: type)
            }
        }
    }
}
