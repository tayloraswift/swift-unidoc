extension Markdown
{
    @frozen public
    enum Outlinable<InlineValue>
    {
        case outlined   (Int)
        case inline     (InlineValue)
    }
}
extension Markdown.Outlinable:Equatable where InlineValue:Equatable
{
}
extension Markdown.Outlinable:Hashable where InlineValue:Hashable
{
}
extension Markdown.Outlinable:Sendable where InlineValue:Sendable
{
}
