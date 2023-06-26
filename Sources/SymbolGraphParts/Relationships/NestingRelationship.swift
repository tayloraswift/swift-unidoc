import Symbols
import Unidoc

public
protocol NestingRelationship
{
    var origin:Symbol.Decl? { get }
    var scope:Symbol? { get }

    var aperture:Unidoc.Decl.Aperture? { get }

    func validate(source phylum:Unidoc.Decl) -> Bool
}
