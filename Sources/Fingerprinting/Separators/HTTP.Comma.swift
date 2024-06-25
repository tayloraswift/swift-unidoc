import HTTP

extension HTTP
{
    @frozen @usableFromInline
    enum Comma:HeaderWordSeparator
    {
        @inlinable
        static var character:Character { "," }
    }
}
