import MarkdownABI

extension Markdown {
    public protocol BlockDirectiveOption: RawRepresentable<String>, Sendable {
    }
}
