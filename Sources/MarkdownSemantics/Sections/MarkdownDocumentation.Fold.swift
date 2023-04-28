import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Fold:MarkdownTree.Block
    {
        /// Folds the binary.
        public final override
        func emit(into binary:inout MarkdownBinary)
        {
            binary.fold()
        }
    }
}
