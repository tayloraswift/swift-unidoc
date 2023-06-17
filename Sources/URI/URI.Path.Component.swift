extension URI.Path
{
    @frozen public
    enum Component:Equatable, Hashable, Sendable
    {
        /// A regular path component. This can be '.' or '..' if at least one
        /// of the dots was percent-encoded.
        case push(String)
        /// '..'
        case pop
    }
}
extension URI.Path.Component
{
    @inlinable public static
    var empty:Self { .push("") }
}
extension URI.Path.Component:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self = .push(stringLiteral)
    }
}
extension URI.Path.Component:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
    public
    init?(_ description:Substring)
    {
        if  let value:Self = try? URI.PathComponentRule<String.Index>.parse(description.utf8)
        {
            self = value
        }
        else
        {
            return nil
        }
    }
}
extension URI.Path.Component:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .empty:
            return "."
        case .pop:
            return ".."
        case .push(let component):
            func hex(uppercasing value:UInt8) -> UInt8
            {
                (value < 10 ? 0x30 : 0x37) + value
            }

            var encoded:[UInt8] = []
                encoded.reserveCapacity(component.utf8.underestimatedCount)
            for byte:UInt8 in component.utf8
            {
                switch byte
                {
                case    0x30 ... 0x39,  // [0-9]
                        0x41 ... 0x5a,  // [A-Z]
                        0x61 ... 0x7a,  // [a-z]
                        0x2d,           // '-'
                        0x2e,           // '.'
                        // not technically a URL character, but browsers won’t render '%3A'
                        // in the URL bar, and ':' is so common in Swift it is not worth
                        // percent-encoding.
                        // the ':' character also appears in legacy USRs.
                        0x3a,           // ':'
                        0x5f,           // '_'
                        0x7e:           // '~'
                    encoded.append(byte)

                case    _:
                    // percent-encode
                    encoded.append(0x25) // '%'
                    encoded.append(hex(uppercasing: byte >> 4))
                    encoded.append(hex(uppercasing: byte & 0x0f))
                }
            }
            return .init(decoding: encoded, as: Unicode.ASCII.self)
        }
    }
}
