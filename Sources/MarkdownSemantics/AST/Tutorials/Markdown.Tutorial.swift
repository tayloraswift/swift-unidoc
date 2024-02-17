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
    public
    func configure(option:String, value:String, from _:SourceReference<Markdown.Source>) throws
    {
        switch option
        {
        case "time":
            //  We don’t support this, or really, believe in its accuracy.
            break

        case "projectFiles":
            //  TODO: unimplemented
            break

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
