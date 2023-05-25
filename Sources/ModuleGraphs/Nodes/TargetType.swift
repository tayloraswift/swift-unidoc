@frozen public
enum TargetType:String, Hashable, Equatable, Sendable
{
    case binary
    case executable
    case regular
    case macro
    case plugin

    //  We will never decode this from a manifest dump. But “extra” symbolgraphs
    //  are obviously snippets.
    case snippet

    case system
    case test
}
extension TargetType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension TargetType:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
