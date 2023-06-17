import Grammar

/// A generic parsing rule that matches sequences of percent-encoded code units
/// and the generic parameter, which is expected to match a single un-escaped
/// UTF-8 code unit.
public
enum PercentEncodedStringRule<UnencodedByte>
    where UnencodedByte:ParsingRule<UInt8>, UnencodedByte.Construction == Void
{
}
extension PercentEncodedStringRule:ParsingRule
{
    public
    typealias Location = UnencodedByte.Location
    public
    typealias Terminal = UnencodedByte.Terminal

    @inlinable public static
    func parse<Source>(_ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> (string:String, unencoded:Bool)
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let start:Location = input.index
        input.parse(as: UnencodedByte.self, in: Void.self)
        let end:Location = input.index
        var string:String = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)

        while   let utf8:[UInt8] = input.parse(
                    as: Pattern.Reduce<PercentEncodedByteRule<Location>, [UInt8]>?.self)
        {
            string += .init(decoding: utf8,                 as: Unicode.UTF8.self)
            let start:Location = input.index
            input.parse(as: UnencodedByte.self, in: Void.self)
            let end:Location = input.index
            string += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
        }
        return (string, end == input.index)
    }
}
