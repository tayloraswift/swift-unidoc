import Symbolics
import Symbols

public
protocol NestingRelationship
{
    var origin:ScalarSymbol? { get }
    var scope:Symbol? { get }

    var aperture:ScalarAperture? { get }

    func validate(source phylum:ScalarPhylum) -> Bool
}
