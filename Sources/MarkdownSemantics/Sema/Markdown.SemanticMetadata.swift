import MarkdownAST

extension Markdown {
    @frozen public struct SemanticMetadata {
        public var options: Options
        public var merge: MergeBehavior?
        public var root: Bool

        @inlinable public init(
            options: Options = [:],
            merge: MergeBehavior? = nil,
            root: Bool = false
        ) {
            self.options = options
            self.merge = merge
            self.root = root
        }
    }
}
extension Markdown.SemanticMetadata {
    mutating func update(docc options: Markdown.BlockOptions) {
        let scope: OptionScope = options.scope ?? .local
        for case let option as Markdown.BlockOption in options.elements {
            guard
            let enabled: Bool = option.value else {
                continue
            }

            self.options[keyPath: option.key] = .init(value: enabled, scope: scope)
        }
    }

    mutating func update(docc metadata: Markdown.BlockMetadata) {
        for directive: Markdown.BlockElement in metadata.elements {
            switch directive {
            case let directive as Markdown.BlockMetadata.DocumentationExtension:
                self.merge = directive.mergeBehavior

            case is Markdown.BlockMetadata.IsRoot:
                self.root = true

            default:
                continue
            }
        }
    }
}
