import MarkdownABI

public
protocol MarkdownModel
{
    init(attaching blocks:[MarkdownBlock])

    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
}
extension MarkdownModel
{
    public
    init(parsing string:String, as flavor:(some MarkdownFlavor).Type)
    {
        self.init(attaching: flavor.parse(string))
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
