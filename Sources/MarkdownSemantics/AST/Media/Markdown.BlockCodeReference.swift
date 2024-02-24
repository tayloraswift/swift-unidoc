import MarkdownABI
import MarkdownAST
import Sources

extension Markdown
{
    public final
    class BlockCodeReference:BlockContainer<BlockElement>
    {
        /// This is the location of the block directive itself, not the code.
        public
        var source:SourceReference<Source>?

        public private(set)
        var language:String?

        /// The title of the snippet. This is entirely fictitious and only used for display
        /// purposes.
        public private(set)
        var title:String?

        /// The name of the snippet, **including** its file extension.
        public private(set)
        var file:String?
        /// A link to the snippet.
        public
        var link:Outlinable<Int32>?
        /// The name of a second snippet, **including** its file extension, which will be used
        /// as the base for computing a diff.
        public private(set)
        var base:DiffBase?

        public
        var code:Markdown.Bytecode?

        init()
        {
            self.source = nil
            self.title = nil
            self.file = nil
            self.base = .auto

            self.code = nil

            super.init([])
        }

        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            if  let code:Markdown.Bytecode = self.code
            {
                binary[.pre] { $0[.class] = "title" } = self.title
                binary[.snippet, { $0[.language] = self.language }] { $0 += code }
            }
            else
            {
                binary[.pre]
                {
                    $0[.dl]
                    {
                        $0[.dt] = "Code"
                        $0[.dd] = "\(self.file ?? "undefined") (unavailable)"
                    }
                }
            }
            if  case .outlined(let reference) = self.link
            {
                binary &= reference
            }

            super.emit(into: &binary)
        }

        public override
        func outline(by register:(Markdown.AnyReference) throws -> Int?) rethrows
        {
            if  case .inline(let file) = self.link,
                let reference:Int = try register(.location(.init(position: .zero, file: file)))
            {
                self.link = .outlined(reference)
            }

            try super.outline(by: register)
        }
    }
}
extension Markdown.BlockCodeReference:Markdown.BlockDirectiveType
{
    public
    func configure(option:String, value:Markdown.SourceString) throws
    {
        let value:String = value.string
        switch option
        {
        case "language":
            //  Cannot check for duplicates, because the language can be guessed from the file
            //  extension.
            self.language = value

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

            //  Guess the language from the file extension
            if  case nil = self.language,
                let i:String.Index = value.lastIndex(of: "."),
                    i < value.endIndex
            {
                self.language = String.init(value[value.index(after: i)...])
            }

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
