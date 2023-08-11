import Symbols
import Unidoc

public
protocol SuperformRelationship:SymbolRelationship<Symbol.Decl, Symbol.Decl>
{
    var kinks:Unidoc.Decl.Kinks { get }

    func validate(source phylum:Unidoc.Decl) -> Bool
}
