import MarkdownAST

extension MarkdownDocumentation
{
    @frozen public
    struct Topic
    {
        public
        let article:[MarkdownBlock]
        public
        let members:[MarkdownInline.Autolink]

        private
        init(article:[MarkdownBlock], members:[MarkdownInline.Autolink])
        {
            self.article = article
            self.members = members
        }
    }
}
extension MarkdownDocumentation.Topic
{
    /// Calls ``yield`` once for each block in the structure. If `members` is true, this
    /// function will materialize the topic’s ``members`` as an unordered list of autolinks
    /// at the end of the ``article``.
    @inlinable public
    func visit(members:Bool = true, _ yield:(MarkdownBlock) throws -> ()) rethrows
    {
        try self.article.forEach(yield)

        guard members
        else
        {
            return
        }

        let items:[MarkdownBlock.Item] = self.members.map
        {
            .init(elements: [MarkdownBlock.Paragraph.init([.autolink($0)])])
        }

        try yield(MarkdownBlock.UnorderedList.init(items))
    }
}
extension MarkdownDocumentation.Topic
{
    init?(_ blocks:borrowing ArraySlice<MarkdownBlock>)
    {
        var blocks:ArraySlice<MarkdownBlock> = copy blocks

        guard
        case (let list as MarkdownBlock.UnorderedList)? = blocks.popLast()
        else
        {
            return nil
        }

        var members:[MarkdownInline.Autolink] = []
            members.reserveCapacity(list.elements.count)

        for item:MarkdownBlock.Item in list.elements
        {
            if  case (let paragraph as MarkdownBlock.Paragraph)? = item.elements.first,
                    item.elements.count == 1,
                case .autolink(let member)? = paragraph.elements.first,
                    paragraph.elements.count == 1
            {
                members.append(member)
            }
            else
            {
                return nil
            }
        }
        //  Promote all (unnested) headings by one level
        for case (let heading as MarkdownBlock.Heading) in blocks
        {
            heading.level -= 1
        }

        self.init(article: .init(blocks), members: members)
    }
}
