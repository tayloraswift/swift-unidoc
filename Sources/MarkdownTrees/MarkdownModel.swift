import MarkdownABI

public
protocol MarkdownModel
{
    init(parser parse:() -> ([MarkdownBlock]))

    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
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

    /// Emits this markdown tree’s ``blocks`` into the given binary.
    /// In most cases, you don’t want to call this API directly, instead
    /// you may want to convert this tree into some higher-level semantic
    /// representation, and turn that into a binary instead.
    ///
    /// This function does not change any internal tree state.
    public
    func emit(into binary:inout MarkdownBinaryEncoder)
    {
        self.visit
        {
            $0.emit(into: &binary)
        }
    }
}
