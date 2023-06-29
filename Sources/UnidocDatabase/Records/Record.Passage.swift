import MarkdownABI

extension Record
{
    @frozen public
    struct Passage:Equatable, Sendable
    {
        public
        let referents:[Referent]
        public
        let markdown:MarkdownBytecode

        init(referents:[Referent], markdown:MarkdownBytecode)
        {
            self.referents = referents
            self.markdown = markdown
        }
    }
}
