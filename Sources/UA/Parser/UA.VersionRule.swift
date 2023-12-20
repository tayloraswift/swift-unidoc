import Grammar

extension UA
{
    enum VersionRule
    {
    }
}
extension UA.VersionRule:ParsingRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> UA.Version
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: UnicodeEncoding.Slash.self)

        if  let (major, _):(Int, Void) = try? input.parse(as:
                (
                    Pattern.UnsignedInteger<UnicodeDigit<Location, Terminal, Int>.Decimal>,
                    UnicodeEncoding.Period
                ).self)
        {
            return .numeric(major, try input.parse(as: UA.NameRule.self))
        }
        else
        {
            return .nominal(try input.parse(as: UA.NameRule.self))
        }
    }
}
