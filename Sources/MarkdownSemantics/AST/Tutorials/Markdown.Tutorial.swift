import MarkdownAST
import Sources

extension Markdown
{
    public
    class Tutorial:BlockElement
    {
        public
        var source:SourceReference<Markdown.Source>?

        public private(set)
        var requirement:String?
        /// The tutorial’s headline, which was extracted from its ``Intro``.
        public private(set)
        var headline:String?
        /// The tutorial’s overview, which is an `@Intro` that has had its ``Intro/title``
        /// removed and stored in ``headline``.
        private(set)
        var overview:Intro?
        private(set)
        var sections:[Section]

        public override
        init()
        {
            self.source = nil

            self.requirement = nil
            self.headline = nil
            self.overview = nil
            self.sections = []

            super.init()
        }

        public final override
        func traverse(with visit:(Markdown.BlockElement) throws -> ()) rethrows
        {
            try super.traverse(with: visit)
            try self.overview?.traverse(with: visit)
            for section:Section in self.sections
            {
                try section.traverse(with: visit)
            }
        }
    }
}
extension Markdown.Tutorial:Markdown.BlockDirectiveType
{
    public final
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

    public final
    func append(_ element:Markdown.BlockElement) throws
    {
        //  Apple won’t tolerate this, but we are not Apple.
        if  case let section as Section = element
        {
            self.sections.append(section)
        }
        else if
            case nil = self.requirement,
            case let requirement as Requirement = element
        {
            self.requirement = requirement.title
        }
        else if
            case nil = self.overview
        {
            guard
            case let intro as Intro = element
            else
            {
                throw StructuralError.intro(type: type(of: element))
            }

            defer { intro.title = nil }
            self.headline = intro.title
            self.overview = intro
        }
        else
        {
            throw StructuralError.child(type: type(of: element))
        }
    }
}
