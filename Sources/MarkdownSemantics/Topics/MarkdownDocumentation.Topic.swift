import MarkdownTrees

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
    init?(_ blocks:__shared ArraySlice<MarkdownBlock>)
    {
        guard case (let list as MarkdownBlock.UnorderedList)? = blocks.last
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

        self.init(article: .init(blocks.dropLast()), members: members)
    }
}
