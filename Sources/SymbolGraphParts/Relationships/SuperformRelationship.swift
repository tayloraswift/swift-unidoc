import Symbols
import Unidoc

public
protocol SuperformRelationship
{
    var source:Symbol.Decl { get }
    var target:Symbol.Decl { get }
    var origin:Symbol.Decl? { get }

    func validate(source phylum:Unidoc.Decl) -> Bool
}
