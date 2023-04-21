public
protocol SuperformRelationship
{
    var source:ScalarSymbolResolution { get }
    var target:ScalarSymbolResolution { get }
    var origin:ScalarSymbolResolution? { get }

    func validate(source phylum:SymbolGraph.Scalar.Phylum) -> Bool
}
