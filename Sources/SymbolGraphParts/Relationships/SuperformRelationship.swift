import Symbols

public
protocol SuperformRelationship
{
    var source:ScalarSymbol { get }
    var target:ScalarSymbol { get }
    var origin:ScalarSymbol? { get }

    func validate(source phylum:ScalarPhylum) -> Bool
}
