import SymbolGraphs
import Unidoc

extension Unidoc
{
    struct Counter<Plane>:Hashable, Equatable, Sendable where Plane:SymbolGraph.PlaneType
    {
        private
        let zone:Edition
        private
        var next:Int32

        init(zone:Edition, next:Int32 = 0)
        {
            self.zone = zone
            self.next = next
        }
    }
}
extension Unidoc.Counter
{
    private mutating
    func increment() -> Int32
    {
        precondition(0 ... 0x00_ff_ff_ff ~= self.next)
        defer { self.next += 1 }
        return self.next
    }
}
extension Unidoc.Counter where Plane:SymbolGraph.PlaneType
{
    mutating
    func id() -> Unidoc.Group.ID
    {
        .init(rawValue: self.zone + (Plane.plane | self.increment()))
    }
}
extension Unidoc.Counter<SymbolGraph.ForeignPlane>
{
    mutating
    func id() -> Unidoc.Scalar
    {
        self.zone + (Plane.plane | self.increment())
    }
}
