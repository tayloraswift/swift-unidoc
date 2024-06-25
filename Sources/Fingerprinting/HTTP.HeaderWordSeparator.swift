import HTTP

extension HTTP
{
    @usableFromInline
    protocol HeaderWordSeparator
    {
        static var character:Character { get }
    }
}
