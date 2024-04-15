extension Unidoc
{
    @frozen public
    enum BuildRoute:String, Sendable
    {
        /// Route for uploading build status and logs.
        case report
        /// Route for uploading labeled symbol graphs.
        case labeled
        /// Route for uploading unlabeled symbol graphs.
        case labeling
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
