import Grammar

extension UA.ParsingRule
{
    enum Component
    {
    }
}
extension UA.ParsingRule.Component:ParsingRule
{
    typealias Location = String.Index
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> UA.Component
        where Source:Collection<UInt8>, Source.Index == Location
    {
        if  let name:String = input.parse(as: UA.NameRule?.self)
        {
            return .single(name, input.parse(as: UA.VersionRule?.self))
        }
        else
        {
            return .group(try input.parse(as: UA.ClauseGroupRule.self))
        }
    }
}
