extension UCF.PatternFilter
{
    @frozen public
    struct Identifier:Equatable, Hashable, Sendable
    {
        @usableFromInline
        let suffix:String

        @inlinable
        init(suffix:String)
        {
            self.suffix = suffix
        }
    }
}
extension UCF.PatternFilter.Identifier:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.suffix.isEmpty ? "_" : self.suffix
    }
}
extension UCF.PatternFilter.Identifier
{
    @inlinable public
    init?(_ pattern:some StringProtocol)
    {
        if  pattern.isEmpty
        {
            return nil
        }
        if  pattern == "_"
        {
            self.init(suffix: "")
        }
        else
        {
            self.init(suffix: String.init(pattern))
        }
    }
}
