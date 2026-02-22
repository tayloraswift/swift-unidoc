import Sources

extension Markdown.Tutorial {
    final class Requirement: Markdown.BlockLeaf {
        public var title: String?

        public override init() {
            self.title = nil
            super.init()
        }
    }
}
extension Markdown.Tutorial.Requirement: Markdown.BlockDirectiveType {
    @frozen public enum Option: String, Markdown.BlockDirectiveOption {
        case title
        case destination
    }

    public func configure(option: Option, value: Markdown.SourceString) throws {
        switch option {
        case .title:
            self.title = value.string

        case .destination:
            break
        }
    }
}
