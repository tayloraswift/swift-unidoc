extension Unidoc
{
    @frozen public
    enum LinkerRoute:String
    {
        case uplink
        case unlink
        case delete
        /// This is not really a linker action, but it is related closely enough to piggyback
        /// on the same route.
        case vintage
    }
}
extension Unidoc.LinkerRoute:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension Unidoc.LinkerRoute:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
