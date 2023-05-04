import Symbolics
import Symbols

public
protocol NestingRelationship
{
    var origin:ScalarSymbol? { get }
    var scope:UnifiedSymbol? { get }

    var aperture:ScalarAperture? { get }

    func validate(source phylum:ScalarPhylum) -> Bool
}
