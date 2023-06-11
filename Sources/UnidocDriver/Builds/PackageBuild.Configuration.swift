extension PackageBuild
{
    @frozen public
    enum Configuration:String
    {
        case debug = "debug"
    }
}
extension PackageBuild.Configuration:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension PackageBuild.Configuration:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
