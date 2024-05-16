extension SSGC
{
    @frozen public
    enum PackageBuildConfiguration:String
    {
        case debug = "debug"
    }
}
extension SSGC.PackageBuildConfiguration:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension SSGC.PackageBuildConfiguration:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
