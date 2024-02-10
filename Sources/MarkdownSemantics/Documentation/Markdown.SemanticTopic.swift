import MarkdownAST

extension Markdown
{
    @frozen public
    struct SemanticTopic
    {
        public
        let article:[Markdown.BlockElement]
        public
        let members:[Markdown.InlineAutolink]

        private
        init(article:[Markdown.BlockElement], members:[Markdown.InlineAutolink])
        {
            self.article = article
            self.members = members
        }
    }
}
extension Markdown.SemanticTopic
{
    /// Calls ``yield`` once for each block in the structure. If `members` is true, this
    /// function will materialize the topic’s ``members`` as an unordered list of autolinks
    /// at the end of the ``article``.
    @inlinable public
    func visit(members:Bool = true, _ yield:(Markdown.BlockElement) throws -> ()) rethrows
    {
        try self.article.forEach(yield)

        guard members
        else
        {
            return
        }

        let items:[Markdown.BlockItem] = self.members.map
        {
            .init(elements: [Markdown.BlockParagraph.init([.autolink($0)])])
        }

        try yield(Markdown.BlockListUnordered.init(items))
    }
}
extension Markdown.SemanticTopic
{
    init?(heading:Markdown.BlockElement?, body blocks:ArraySlice<Markdown.BlockElement>)
    {
        var blocks:ArraySlice<Markdown.BlockElement> = copy blocks

        guard
        case (let list as Markdown.BlockListUnordered)? = blocks.popLast()
        else
        {
            return nil
        }

        var members:[Markdown.InlineAutolink] = []
            members.reserveCapacity(list.elements.count)

        for item:Markdown.BlockItem in list.elements
        {
            if  case (let paragraph as Markdown.BlockParagraph)? = item.elements.first,
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
        for case (let heading as Markdown.BlockHeading) in blocks
        {
            heading.level -= 1
        }

        if  let heading:Markdown.BlockElement
        {
            self.init(article: [heading] + blocks, members: members)
        }
        else
        {
            self.init(article: [Markdown.BlockElement].init(blocks), members: members)
        }
    }
}
