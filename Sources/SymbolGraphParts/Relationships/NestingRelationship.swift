import Symbols

public protocol NestingRelationship: SymbolRelationship where Source == Symbol.Decl {
    var kinks: Phylum.Decl.Kinks { get }

    func validate(source phylum: Phylum.Decl) -> Bool
}
