import Lexemes
import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Parameter
    {
        public
        let identifier:IdentifierLexeme
        public
        var elements:[MarkdownTree.Block]

        @inlinable public
        init(identifier:IdentifierLexeme, elements:[MarkdownTree.Block])
        {
            self.identifier = identifier
            self.elements = elements
        }
    }
}
extension MarkdownDocumentation.Parameter
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.dt] = self.identifier.description
        binary[.dd]
        {
            for block:MarkdownTree.Block in self.elements
            {
                block.emit(into: &$0)
            }
        }
    }
}
