import SymbolGraphs
import Unidoc

extension Unidoc
{
    struct Counter<Plane>:Hashable, Equatable, Sendable where Plane:SymbolGraph.PlaneType
    {
        public
        let zone:Edition
        public
        var next:Int32

        @inlinable public
        init(zone:Edition, next:Int32 = 0)
        {
            self.zone = zone
            self.next = next
        }
    }
}
extension Unidoc.Counter
{
    mutating
    func id() -> Unidoc.Scalar
    {
        precondition(0 ... 0x00_ff_ff_ff ~= self.next)
        defer { self.next += 1 }
        return self.zone + (Plane.plane | self.next)
    }
}
