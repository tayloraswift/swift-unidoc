import Sources

extension Markdown {
    final class BlockOption: Markdown.BlockLeaf {
        typealias Key = WritableKeyPath<
            Markdown.SemanticMetadata.Options,
            Markdown.SemanticMetadata.Option<Bool>?
        >

        let key: Key

        private(set) var value: Bool?

        init(key: Key) {
            self.key = key
            self.value = nil
            super.init()
        }
    }
}
extension Markdown.BlockOption: Markdown.BlockDirectiveType {
    enum Option: String, Markdown.BlockDirectiveOption {
        case `_` = ""
    }

    func configure(option: Option, value: Markdown.SourceString) throws {
        switch option {
        case .`_`:
            guard case nil = self.value else {
                throw option.duplicate
            }

            if  let value: Bool = .init(value.string) {
                self.value = value
            } else if
                case .enabled = try option.case(value, of: Enabledness.self) {
                self.value = true
            } else {
                self.value = false
            }
        }
    }
}
