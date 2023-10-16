import Grammar

extension UA
{
    enum ParsingRule
    {
    }
}
extension UA.ParsingRule:ParsingRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> [UA.Component]
        where Source:Collection<UInt8>, Source.Index == Location
    {
        try input.parse(as: Pattern.Join<Component, Separator, [UA.Component]>.self)
    }
}
