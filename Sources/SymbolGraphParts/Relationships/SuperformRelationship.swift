import Symbolics
import Symbols

public
protocol SuperformRelationship
{
    var source:Symbol.Scalar { get }
    var target:Symbol.Scalar { get }
    var origin:Symbol.Scalar? { get }

    func validate(source phylum:ScalarPhylum) -> Bool
}
