import Symbols

public
protocol SuperformRelationship:SymbolRelationship<Symbol.Decl, Symbol.Decl>
{
    var kinks:Phylum.Decl.Kinks { get }

    func validate(source phylum:Phylum.Decl) -> Bool
}
