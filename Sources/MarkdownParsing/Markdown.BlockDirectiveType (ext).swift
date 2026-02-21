import MarkdownAST

extension Markdown.BlockDirectiveType {
    func configure(option: String, value: Markdown.SourceString, block: String) throws {
        guard
        let option: Option = .init(rawValue: option) else {
            throw Markdown.BlockDirectiveUnexpectedOptionError.init(
                option: option,
                block: block
            )
        }

        try self.configure(option: option, value: value)
    }
}
