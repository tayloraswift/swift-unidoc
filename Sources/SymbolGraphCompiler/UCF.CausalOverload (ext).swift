import Symbols
import UCF

extension UCF.CausalOverload {
    static func feature(_ decl: SSGC.Decl, self heir: Symbol.Decl) -> Self {
        .init(
            traits: decl.traits(self: heir),
            decl: decl.id,
            heir: heir,
            documented: decl.comment != nil,
            inherited: true
        )
    }
    static func decl(_ decl: SSGC.Decl) -> Self {
        .init(
            traits: decl.traits,
            decl: decl.id,
            heir: nil,
            documented: decl.comment != nil,
            inherited: false
        )
    }
}
