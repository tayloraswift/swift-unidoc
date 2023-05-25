extension Toolchain
{
    @frozen public
    enum BuildConfiguration:String
    {
        case debug = "debug"
    }
}
extension Toolchain.BuildConfiguration:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension Toolchain.BuildConfiguration:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
