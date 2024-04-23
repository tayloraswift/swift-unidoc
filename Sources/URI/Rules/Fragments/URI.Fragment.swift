extension URI
{
    @frozen public
    struct Fragment:Equatable, Hashable, Sendable
    {
        public
        var decoded:String

        @inlinable public
        init(decoded:String)
        {
            self.decoded = decoded
        }
    }
}
extension URI.Fragment:RawRepresentable
{
    /// The ``rawValue`` of a fragment is the percent-``decoded`` string.
    @inlinable public
    init(rawValue:String) { self.init(decoded: rawValue) }

    /// Returns the percent-``decoded`` string.
    @inlinable public
    var rawValue:String { self.decoded }
}
extension URI.Fragment:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension URI.Fragment
{
    /// Parses a fragment from a percent-encoded string. This parser does not expect a leading
    /// hashtag (`#`).
    public
    init?(decoding string:Substring)
    {
        guard case (let decoded, _)? = try? PercentEncodedStringRule<
            URI.FragmentRule<String.Index>.UnencodedByte>.parse(string.utf8)
        else
        {
            return nil
        }

        self.init(rawValue: decoded)
    }
    /// Formats the fragment as a string without a leading hashtag (`#`).
    ///
    /// This property percent-encodes the fragment as needed.
    @inlinable public
    var encoded:String { EncodingSet.encode(self.rawValue) }
}
extension URI.Fragment:CustomStringConvertible
{
    /// Formats the fragment as a string with a leading hashtag (`#`).
    ///
    /// This property percent-encodes the fragment as needed.
    @inlinable public
    var description:String { "#\(self.encoded)" }
}
