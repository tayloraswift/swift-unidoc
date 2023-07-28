extension Unidoc
{
    @frozen public
    struct Counter<Plane>:Hashable, Equatable, Sendable where Plane:UnidocPlaneType
    {
        public
        let zone:Zone
        public
        var next:Int32

        @inlinable public
        init(zone:Zone, next:Int32 = 0)
        {
            self.zone = zone
            self.next = next
        }
    }
}
extension Unidoc.Counter
{
    @inlinable public mutating
    func id() -> Unidoc.Scalar
    {
        precondition(0 ... 0x00_ff_ff_ff ~= self.next)
        defer { self.next += 1 }
        return self.zone + (Plane.plane | self.next)
    }
}
