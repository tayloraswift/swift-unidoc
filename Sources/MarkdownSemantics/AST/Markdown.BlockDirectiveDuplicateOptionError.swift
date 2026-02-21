extension Markdown {
    struct BlockDirectiveDuplicateOptionError<
        Option
    >: Error where Option: BlockDirectiveOption {
        let option: Option
    }
}
extension Markdown.BlockDirectiveDuplicateOptionError: CustomStringConvertible {
    var description: String {
        "duplicate option '\(self.option.rawValue)'"
    }
}
