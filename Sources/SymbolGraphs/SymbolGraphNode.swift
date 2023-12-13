public
protocol SymbolGraphNode<ID>
{
    associatedtype Plane:SymbolGraph.PlaneType
    associatedtype ID:Hashable

    var isCitizen:Bool { get }
}
