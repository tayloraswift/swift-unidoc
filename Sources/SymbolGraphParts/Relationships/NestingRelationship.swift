import Symbolics
import Symbols

public
protocol NestingRelationship
{
    var origin:Symbol.Scalar? { get }
    var scope:Symbol? { get }

    var aperture:ScalarAperture? { get }

    func validate(source phylum:ScalarPhylum) -> Bool
}
