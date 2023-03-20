import SymbolColonies

struct ExtensionBlockIndex
{
    private
    var extendees:[String: SymbolIdentifier]

    private 
    init(extendees:[String: SymbolIdentifier] = [:])
    {
        self.extendees = extendees
    }
}
extension ExtensionBlockIndex
{
    func extendee(of block:String) throws -> SymbolIdentifier
    {
        if let type:SymbolIdentifier = extendees[block]
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
            case (.block(let name), .scalar(let usr)):
                self.extendees[name] = usr.id

            case (.block, _):
                //  Extension block cannot extend a compound, or another
                //  extension block.
                throw SymbolRelationshipError.target(of: relationship)
            
            case (_, _):
                //  Extension block must have an extension block name.
                throw SymbolRelationshipError.source(of: relationship)
            }
        }
    }
}
