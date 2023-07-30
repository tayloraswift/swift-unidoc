import UnidocRecords

extension Record.Stem:ExpressibleByStringLiteral
{
    public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
