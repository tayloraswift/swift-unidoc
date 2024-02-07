extension SPM.Build
{
    @frozen public
    enum Configuration:String
    {
        case debug = "debug"
    }
}
extension SPM.Build.Configuration:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension SPM.Build.Configuration:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
