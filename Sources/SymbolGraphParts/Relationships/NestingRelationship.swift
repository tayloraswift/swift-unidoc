import Symbols
import Unidoc

public
protocol NestingRelationship:SymbolRelationship
{
    var scope:Symbol { get }

    var kinks:Unidoc.Decl.Kinks { get }

    func validate(source phylum:Unidoc.Decl) -> Bool
}
