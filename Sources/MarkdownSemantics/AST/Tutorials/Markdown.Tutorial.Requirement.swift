import Sources

extension Markdown.Tutorial
{
    final
    class Requirement:Markdown.BlockLeaf
    {
        public
        var title:String?

        public override
        init()
        {
            self.title = nil
            super.init()
        }
    }
}
extension Markdown.Tutorial.Requirement:Markdown.BlockDirectiveType
{
    public
    func configure(option:String, value:Markdown.SourceString) throws
    {
        switch option
        {
        case "title":
            self.title = value.string

        case "destination":
            return

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
