import Symbolics
import Symbols

public
protocol NestingRelationship
{
    var origin:Symbol.Scalar? { get }
    var scope:Symbol? { get }

    var virtuality:ScalarVirtuality? { get }

    func validate(source phylum:ScalarPhylum) -> Bool
}
