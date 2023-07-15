import Symbols
import Unidoc

public
protocol NestingRelationship
{
    var origin:Symbol.Decl? { get }
    var scope:Symbol? { get }

    var customization:Unidoc.Decl.Customization? { get }

    func validate(source phylum:Unidoc.Decl) -> Bool
}
