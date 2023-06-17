import Grammar

/// A parsing rule that matches a *single* percent-encoded UTF-8 code unit,
/// such as `%20`. Its construction (``UInt8``) is the encoded code unit.
public
enum PercentEncodedByteRule<Location>
{
}
extension PercentEncodedByteRule:ParsingRule
{
    public
    typealias Terminal = UInt8

    @inlinable public static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> UInt8
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: UnicodeEncoding<Location, Terminal>.Percent.self)
        let high:UInt8 = try input.parse(
            as: UnicodeDigit<Location, Terminal, UInt8>.Hex.self)
        let low:UInt8 = try input.parse(
            as: UnicodeDigit<Location, Terminal, UInt8>.Hex.self)
        return high << 4 | low
    }
}
