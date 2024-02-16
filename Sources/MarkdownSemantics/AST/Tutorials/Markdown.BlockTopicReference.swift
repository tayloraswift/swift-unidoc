import Doclinks

extension Markdown
{
    final
    class BlockTopicReference:Markdown.BlockLeaf
    {
        public
        var doclink:Doclink?

        public override
        init()
        {
            self.doclink = nil
            super.init()
        }
    }
}
extension Markdown.BlockTopicReference:Markdown.BlockDirectiveType
{
    public
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "tutorial":
            guard case nil = self.doclink
            else
            {
                throw ArgumentError.duplicate(option)
            }
            guard
            let doclink:Doclink = .init(value)
            else
            {
                throw ArgumentError.doclink(value)
            }

            self.doclink = doclink

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
