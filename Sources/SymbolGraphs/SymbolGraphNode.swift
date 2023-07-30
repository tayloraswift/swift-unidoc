import Unidoc

public
protocol SymbolGraphNode<ID>
{
    associatedtype Plane:UnidocPlaneType
    associatedtype ID:Hashable

    var isCitizen:Bool { get }
}
