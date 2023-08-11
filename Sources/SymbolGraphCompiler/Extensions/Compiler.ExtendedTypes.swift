import Symbols
import SymbolGraphParts

extension Compiler
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
extension Compiler.ExtendedTypes
{
    func extendee(of block:Symbol.Block) throws -> Symbol.Decl
    {
        if let type:Symbol.Decl = extendees[block]
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

        for case .extension(let relationship) in colony.relationships
        {
            guard case nil = self.extendees.updateValue(relationship.target,
                    forKey: relationship.source)
            else
            {
                throw Compiler.DuplicateSymbolError.block(relationship.source)
            }
        }
    }
}
