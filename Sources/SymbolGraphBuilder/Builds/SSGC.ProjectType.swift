extension SSGC
{
    @frozen public
    enum ProjectType:String, Equatable, Sendable
    {
        case package
        case book
    }
}
extension SSGC.ProjectType:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension SSGC.ProjectType:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
