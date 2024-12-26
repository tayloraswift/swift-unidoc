extension UCF.PatternFilter
{
    struct Identifier:Equatable, Hashable, Sendable
    {
        let value:String?

        init(value:String?)
        {
            self.value = value
        }
    }
}
extension UCF.PatternFilter.Identifier
{
    init?(_ pattern:some StringProtocol)
    {
        if  pattern.isEmpty
        {
            return nil
        }
        if  pattern == "_"
        {
            self.init(value: nil)
        }
        else
        {
            self.init(value: String.init(pattern))
        }
    }
}
