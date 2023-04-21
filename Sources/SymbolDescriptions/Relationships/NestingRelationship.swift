public
protocol NestingRelationship
{
    var origin:ScalarSymbolResolution? { get }
    var scope:UnifiedSymbolResolution? { get }

    var virtuality:SymbolGraph.Scalar.Virtuality? { get }

    func validate(source phylum:SymbolGraph.Scalar.Phylum) -> Bool
}
