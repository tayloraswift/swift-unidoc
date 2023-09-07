import Unidoc

@frozen public
struct SnapshotReceipt:Equatable, Hashable, Sendable
{
    public
    let id:String
    public
    let zone:Unidoc.Zone
    public
    let overwritten:Bool

    @inlinable public
    init(id:String, zone:Unidoc.Zone, overwritten:Bool)
    {
        self.id = id
        self.zone = zone
        self.overwritten = overwritten
    }
}
extension SnapshotReceipt
{
    @inlinable public
    var package:Int32 { self.zone.package }

    @inlinable public
    var version:Int32 { self.zone.version }
}
