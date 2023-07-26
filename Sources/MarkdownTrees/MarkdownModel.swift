import MarkdownABI

public
protocol MarkdownModel
{
    init(parser parse:() -> ([MarkdownBlock]))
}
extension MarkdownModel
{
    @inlinable public
    init(parsing string:String,
        from id:Int = 0,
        with parser:some MarkdownParser,
        as flavor:(some MarkdownFlavor).Type)
    {
        self.init
        {
            var blocks:[MarkdownBlock] = parser.parse(string, from: id)
            flavor.transform(blocks: &blocks)
            return blocks
        }
    }
}
