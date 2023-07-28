import MarkdownTrees

@frozen public
struct MarkdownSupplement
{
    public
    var headline:Headline?
    public
    var body:MarkdownDocumentation

    @inlinable public
    init(headline:Headline?, body:MarkdownDocumentation)
    {
        self.headline = headline
        self.body = body
    }
}
extension MarkdownSupplement:MarkdownModel
{
    public
    init(parser parse:() -> [MarkdownBlock])
    {
        let blocks:[MarkdownBlock] = parse()

        if  case (let heading as MarkdownBlock.Heading)? = blocks.first, heading.level == 1
        {
            self.init(headline: .init(heading), body: .init(attaching: blocks.dropFirst()))
        }
        else
        {
            self.init(headline: nil, body: .init(attaching: blocks))
        }
    }
}
