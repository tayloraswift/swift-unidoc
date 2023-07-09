extension NumericVersion
{
    /// The tag bit indicating the precision of a numeric version.
    @usableFromInline @frozen internal
    enum Precision:Int64
    {
        case major = 1
        case minor = 2
        case patch = 3
    }
}
