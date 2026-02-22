import Symbols

extension SSGC {
    struct ExtensionLayer {
        let extendee: Extendee

        var conformances: Set<Symbol.Decl>
        var features: Set<Symbol.Decl>
        var nested: Set<Symbol.Decl>

        var blocks: [(id: Symbol.Block, block: SSGC.Extension.Block)]

        init(
            extendee: Extendee,
            conformances: Set<Symbol.Decl> = [],
            features: Set<Symbol.Decl> = [],
            nested: Set<Symbol.Decl> = [],
            blocks: [(id: Symbol.Block, block: SSGC.Extension.Block)] = []
        ) {
            self.extendee = extendee

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.blocks = blocks
        }
    }
}
