extension Unidoc
{
    @frozen public
    enum BuildRoute:String, Sendable
    {
        /// Route for uploading symbol graphs.
        case artifact
        /// Route for uploading build status and logs.
        case report
    }
}
extension Unidoc.BuildRoute:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension Unidoc.BuildRoute:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
