import MarkdownAST
import Sources

extension Markdown
{
    public final
    class Tutorial:BlockContainer<Tutorial.Section>
    {
        public
        var source:SourceReference<Markdown.Source>?
        private(set)
        var intro:Intro?

        public
        init()
        {
            self.source = nil
            self.intro = nil
            super.init([])
        }
    }
}
extension Markdown.Tutorial:Markdown.BlockDirectiveType
{
    public
    func configure(option:String, value:String) throws
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

    public
    func append(_ element:Markdown.BlockElement) throws
    {
        //  Apple won’t tolerate this, but we are not Apple.
        if  case let section as Section = element
        {
            self.elements.append(section)
        }
        else if
            case nil = self.intro
        {
            guard
            case let intro as Intro = element
            else
            {
                throw StructuralError.intro(type: type(of: element))
            }

            self.intro = intro
        }
        else
        {
            throw StructuralError.child(type: type(of: element))
        }
    }
}
