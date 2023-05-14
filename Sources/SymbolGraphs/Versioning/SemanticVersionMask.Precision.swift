import SemanticVersions

extension SemanticVersionMask
{
    /// The precision tag used by this ``SemanticVersionMask``’s BSON ABI.
    @usableFromInline @frozen internal
    enum Precision:Int64
    {
        case major = 1
        case minor = 2
        case patch = 3
    }
}
