import Grammar

extension URI
{
    /// A parsing rule that matches a leading hashtag (`#`), followed by an arbitrary
    /// percent-encoded string.
    ///
    /// This parser accepts strings that are not valid fragments, such as those that contain
    /// additional hashtags (`#`) or control characters.
    enum FragmentRule<Location>
    {
    }
}
extension URI.FragmentRule:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> URI.Fragment
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: UnicodeEncoding<Location, UInt8>.Hashtag.self)
        let (decoded, _):(String, Bool) = try input.parse(
            as: PercentEncodedStringRule<UnencodedByte>.self)
        return .init(decoded: decoded)
    }
}
