extension Unidoc.BuildForm
{
    @frozen public
    enum Action:Equatable, Sendable
    {
        case submit
        case cancel
    }
}
extension Unidoc.BuildForm.Action:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .submit:   "submit"
        case .cancel:   "cancel"
        }
    }
}
extension Unidoc.BuildForm.Action:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "submit":  self = .submit
        case "cancel":  self = .cancel
        default:        return nil
        }
    }
}
