import SymbolGraphParts
import Symbols

extension SSGC {
    struct ExtendedTypes {
        private var extendees: [Symbol.Block: Symbol.Decl]

        private init(extendees: [Symbol.Block: Symbol.Decl] = [:]) {
            self.extendees = extendees
        }
    }
}
extension SSGC.ExtendedTypes {
    func extendee(of block: Symbol.Block) throws -> Symbol.Decl {
        if let type: Symbol.Decl = extendees[block] {
            return type
        } else {
            throw SSGC.Extension.BlockError.unclaimed(block)
        }
    }
}
extension SSGC.ExtendedTypes {
    init(indexing extensions: __shared [Symbol.ExtensionRelationship]) throws {
        self.init()

        for edge: Symbol.ExtensionRelationship in extensions {
            guard case nil = self.extendees.updateValue(edge.target, forKey: edge.source) else {
                throw SSGC.Extension.BlockError.duplicate(edge.source)
            }
        }
    }
}
