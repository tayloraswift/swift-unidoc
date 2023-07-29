import Unidoc

@frozen public
struct SnapshotReceipt:Equatable, Hashable, Sendable
{
    public
    let package:Int32
    public
    let version:Int32
    public
    let overwritten:Bool
    public
    let id:String

    @inlinable public
    init(overwritten:Bool, package:Int32, version:Int32, id:String)
    {
        self.overwritten = overwritten
        self.package = package
        self.version = version
        self.id = id
    }
}
extension SnapshotReceipt
{
    @inlinable public
    var zone:Unidoc.Zone
    {
        .init(package: self.package, version: self.version)
    }
}
