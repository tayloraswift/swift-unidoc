import MarkdownAST

extension Markdown
{
    @frozen public
    struct SemanticMetadata
    {
        public
        var merge:MergeBehavior?
        public
        var root:Bool

        @inlinable public
        init(merge:MergeBehavior? = nil, root:Bool = false)
        {
            self.merge = merge
            self.root = root
        }
    }
}
extension Markdown.SemanticMetadata
{
    mutating
    func update(docc metadata:Markdown.BlockMetadata)
    {
        for directive:Markdown.BlockElement in metadata.elements
        {
            switch directive
            {
            case let directive as Markdown.BlockMetadata.DocumentationExtension:
                self.merge = directive.mergeBehavior

            case is Markdown.BlockMetadata.IsRoot:
                self.root = true

            default:
                continue
            }
        }
    }
}
