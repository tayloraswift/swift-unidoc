import MarkdownAST
import Sources

extension Markdown
{
    public final
    class Tutorial:BlockArticle
    {
        public private(set)
        var requirement:String?

        public override
        init()
        {
            self.requirement = nil
            super.init()
        }

        public override
        func append(_ element:Markdown.BlockElement) throws
        {
            if  case nil = self.requirement,
                case let requirement as Requirement = element
            {
                self.requirement = requirement.title
            }
            else
            {
                try super.append(element)
            }
        }
    }
}
extension Markdown.Tutorial:Markdown.BlockDirectiveType
{
    @frozen public
    enum Option:String, Markdown.BlockDirectiveOption
    {
        //  We don’t support this, or really, believe in its accuracy.
        case time
        //  TODO: unimplemented
        case projectFiles
    }

    public
    func configure(option:Option, value:Markdown.SourceString)
    {
    }
}
