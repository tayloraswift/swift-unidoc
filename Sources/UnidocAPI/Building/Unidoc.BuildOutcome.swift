extension Unidoc
{
    @frozen public
    enum BuildOutcome:String, Sendable
    {
        case failure
        case success = "labeled"
        case successUnlabeled = "unlabeled"
    }
}
extension Unidoc.BuildOutcome:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension Unidoc.BuildOutcome:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
