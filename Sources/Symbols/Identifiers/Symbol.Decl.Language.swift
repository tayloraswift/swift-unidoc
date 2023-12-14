extension Symbol.Decl
{
    @frozen public
    struct Language:Equatable, Hashable, Sendable
    {
        public
        let ascii:UInt8

        /// Creates a language code from an ASCII scalar. Traps if the scalar is not ASCII.
        @inlinable public
        init(ascii:UInt8)
        {
            precondition(ascii & 0x80 == 0)

            self.ascii = ascii
        }
    }
}
extension Symbol.Decl.Language
{
    @inlinable public
    init?(_ scalar:Unicode.Scalar)
    {
        if  scalar.isASCII
        {
            self.init(ascii: UInt8.init(scalar.value))
        }
        else
        {
            return nil
        }
    }

    /// C.
    @inlinable public static
    var c:Self { .init(ascii: 0x63) }

    /// Swift.
    @inlinable public static
    var s:Self { .init(ascii: 0x73) }
}
extension Symbol.Decl.Language:CustomStringConvertible
{
    @inlinable public
    var description:String { .init(Unicode.Scalar.init(self.ascii)) }
}
