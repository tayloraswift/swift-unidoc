extension Symbol
{
    /// A scalar declaration symbol.
    @frozen public
    struct Decl:Sendable
    {
        /// The symbol’s string value, without an interior colon.
        public
        let rawValue:String

        @inlinable internal
        init(unchecked rawValue:String)
        {
            self.rawValue = rawValue
        }
    }
}
extension Symbol.Decl:RawRepresentable
{
    @inlinable public
    init?(rawValue:String)
    {
        if !rawValue.isEmpty
        {
            self.rawValue = rawValue
        }
        else
        {
            return nil
        }
    }
}
extension Symbol.Decl
{
    /// Creates a symbol identifier from the given language prefix and
    /// mangled suffix. This initializer does not validate the suffix.
    @inlinable public
    init(_ language:Language, ascii suffix:some StringProtocol)
    {
        self.init(unchecked: "\(language)\(suffix)")
    }
    /// Creates a symbol identifier from the given language prefix and
    /// mangled suffix, returning nil if the suffix contains characters
    /// that are not allowed to appear in a symbol identifier.
    ///
    /// Valid characters are `_`, `[A-Z]`, `[a-z]`, `[0-9]`, '.', '-', and `@`.
    @inlinable public
    init?(_ language:Language, _ suffix:some StringProtocol)
    {
        for ascii:UInt8 in suffix.utf8
        {
            switch ascii
            {
            //    '-'   '.'   '_'   'A' ... 'Z'    'a' ... 'z'    '0' ... '9',   '@'
            case 0x2d, 0x2e, 0x5f, 0x41 ... 0x5a, 0x61 ... 0x7a, 0x30 ... 0x39, 0x40:
                continue
            default:
                return nil
            }
        }
        self.init(language, ascii: suffix)
    }

    @inlinable public
    var language:Language
    {
        //  Should not be possible to generate an empty symbol identifier.
        .init(ascii: self.rawValue.utf8.first!)
    }
    @inlinable public
    var suffix:Substring
    {
        self.rawValue.suffix(from: self.rawValue.utf8.index(
            after: self.rawValue.startIndex))
    }
}
extension Symbol.Decl:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue.utf8.elementsEqual(rhs.rawValue.utf8)
    }
}
extension Symbol.Decl:Hashable
{
    @inlinable public
    func hash(into hasher:inout Hasher)
    {
        for byte:UInt8 in self.rawValue.utf8
        {
            byte.hash(into: &hasher)
        }
    }
}
extension Symbol.Decl:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue.utf8.lexicographicallyPrecedes(rhs.rawValue.utf8)
    }
}

extension Symbol.Decl:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.language):\(self.suffix)"
    }
}
extension Symbol.Decl:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:__shared String)
    {
        self.init(fragments: description.split(separator: ":", maxSplits: 1,
            omittingEmptySubsequences: false))
    }
    @inlinable internal
    init?(fragments:__shared [Substring])
    {
        if  fragments.count == 2,
            let language:Unicode.Scalar = .init(fragments[0]),
            let language:Language = .init(language)
        {
            self.init(language, fragments[1])
        }
        else
        {
            return nil
        }
    }
}

@_spi(testable)
extension Symbol.Decl:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(unchecked: stringLiteral) }
}
