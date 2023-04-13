public
protocol SuperformRelationship
{
    var source:ScalarSymbolResolution { get }
    var target:ScalarSymbolResolution { get }
    var origin:ScalarSymbolResolution? { get }
}
