import SymbolGraphParts
import Symbols

extension SSGC
{
    struct ExtendedTypes
    {
        private
        var extendees:[Symbol.Block: Symbol.Decl]

        private
        init(extendees:[Symbol.Block: Symbol.Decl] = [:])
        {
            self.extendees = extendees
        }
    }
}
extension SSGC.ExtendedTypes
{
    func extendee(of block:Symbol.Block) throws -> Symbol.Decl
    {
        if let type:Symbol.Decl = extendees[block]
        {
            return type
        }
        else
        {
            throw SSGC.UnclaimedBlockError.init(unclaimed: block)
        }
    }
}
extension SSGC.ExtendedTypes
{
    init(indexing colony:__shared SymbolGraphPart) throws
    {
        self.init()

        for case .extension(let relationship) in colony.relationships
        {
            guard case nil = self.extendees.updateValue(relationship.target,
                    forKey: relationship.source)
            else
            {
                throw SSGC.DuplicateSymbolError.block(relationship.source)
            }
        }
    }
}
