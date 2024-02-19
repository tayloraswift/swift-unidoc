extension Markdown
{
    @frozen public
    enum Outlinable<InlineValue>:Equatable, Hashable, Sendable
        where InlineValue:Equatable & Hashable & Sendable
    {
        case outlined   (Int)
        case inline     (InlineValue)
    }
}
