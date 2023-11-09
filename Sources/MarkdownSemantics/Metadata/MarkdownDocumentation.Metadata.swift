import MarkdownAST

extension MarkdownDocumentation
{
    @frozen public
    struct Metadata
    {
        public
        var merge:MergeBehavior?

        @inlinable public
        init(merge:MergeBehavior? = nil)
        {
            self.merge = merge
        }
    }
}
extension MarkdownDocumentation.Metadata
{
    mutating
    func update(with blocks:[MarkdownBlock])
    {
        for case let block as MarkdownBlock.Directive in blocks
        {
            switch block.name
            {
            case "DocumentationExtension":
                for (label, argument):(String, String) in block.arguments
                {
                    switch (label, argument)
                    {
                    case ("mergeBehavior", "append"):   self.merge = .append
                    case ("mergeBehavior", "override"): self.merge = .override
                    case _:                             continue
                    }
                }

            //  We don’t support these.
            case "DisplayName":
                fallthrough

            case _:
                continue
            }
        }
    }
}
