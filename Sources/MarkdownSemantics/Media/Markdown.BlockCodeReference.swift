import MarkdownAST
import Sources

extension Markdown
{
    public final
    class BlockCodeReference:BlockContainer<BlockElement>
    {
        public
        var source:SourceReference<Source>?

        private(set)
        var title:String?

        /// The name of the snippet, **including** its file extension.
        public private(set)
        var file:String?
        /// The name of a second snippet, **including** its file extension, which will be used
        /// as the base for computing a diff.
        public private(set)
        var base:DiffBase?

        init()
        {
            self.source = nil
            self.title = nil
            self.file = nil
            self.base = .auto

            super.init([])
        }
    }
}
extension Markdown.BlockCodeReference:Markdown.BlockDirectiveType
{
    public
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "title", "name":
            guard case nil = self.title
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.title = value

        case "file":
            guard case nil = self.file
            else
            {
                throw ArgumentError.duplicated(option)
            }

            self.file = value

        case "base", "previousFile":
            switch self.base
            {
            case nil:       throw ArgumentError.resetContradictsBase
            case .file?:    throw ArgumentError.duplicated(option)
            case .auto?:    break
            }

            self.base = .file(value)

        case "reset": // Legacy DocC syntax
            switch self.base
            {
            case nil:       throw ArgumentError.duplicated(option)
            case .file?:    throw ArgumentError.resetContradictsBase
            case .auto?:    break
            }

            switch value
            {
            case "true":    self.base = nil
            case "false":   break
            case let value: throw ArgumentError.reset(value)
            }

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
