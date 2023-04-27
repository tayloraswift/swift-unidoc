import MarkdownABI

public
protocol MarkdownModel
{
    func visit(_ yield:(MarkdownTree.Block) throws -> ()) rethrows
}
extension MarkdownModel
{
    /// Replaces symbolic codelinks in this markdown tree’s inline content
    /// with references.
    public
    func outline(by register:(_ symbol:String) throws -> UInt32?) rethrows
    {
        try self.visit { try $0.outline(by: register) }
    }
    
    /// Emits this markdown tree’s ``blocks`` into the given binary.
    /// In most cases, you don’t want to call this API directly, instead
    /// you may want to convert this tree into some higher-level semantic
    /// representation, and turn that into a binary instead.
    ///
    /// This function does not change any internal tree state.
    public
    func emit(into binary:inout MarkdownBinary)
    {
        self.visit
        {
            $0.emit(into: &binary)
        }
    }
}
