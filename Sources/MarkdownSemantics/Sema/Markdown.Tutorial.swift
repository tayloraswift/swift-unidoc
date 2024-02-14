import MarkdownAST
import Sources

extension Markdown
{
    public final
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

        public override
        func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
            try self.traverse { try $0.outline(by: register) }
        }

        public override
        func traverse(_ visit:(Markdown.BlockElement) throws -> ()) rethrows
        {
            try super.traverse(visit)
            try self.overview?.traverse(visit)
            for section:Section in self.sections
            {
                try section.traverse(visit)
            }
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
