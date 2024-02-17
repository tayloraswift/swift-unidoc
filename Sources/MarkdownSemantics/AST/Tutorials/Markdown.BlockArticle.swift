import MarkdownAST
import Sources

extension Markdown
{
    public
    class BlockArticle:BlockElement
    {
        public
        var source:SourceReference<Source>?

        /// The article’s headline, which was extracted from its ``Intro``.
        public private(set)
        var headline:String?
        /// The article’s overview, which is an `@Intro` that has had its ``Intro/title``
        /// removed and stored in ``headline``.
        private(set)
        var overview:Intro?
        private(set)
        var sections:[BlockElement]

        public override
        init()
        {
            self.source = nil

            self.headline = nil
            self.overview = nil
            self.sections = []

            super.init()
        }

        public final override
        func traverse(with visit:(BlockElement) throws -> ()) rethrows
        {
            try super.traverse(with: visit)
            try self.overview?.traverse(with: visit)
            for section:BlockElement in self.sections
            {
                try section.traverse(with: visit)
            }
        }

        public
        func append(_ element:BlockElement) throws
        {
            //  Apple won’t tolerate this, but we are not Apple.
            if  case let section as Section = element
            {
                self.sections.append(section)
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
                //  `@Tutorial` cannot contain these, but `@Article` can.
                self.sections.append(element)
            }
        }
    }
}
