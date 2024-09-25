import URI

extension Unidoc
{
    @frozen public
    enum LinkerRoute:String, URI.Path.ComponentConvertible
    {
        case uplink
        case unlink
        case delete
        /// This is not really a linker action, but it is related closely enough to piggyback
        /// on the same route.
        case vintage
    }
}
