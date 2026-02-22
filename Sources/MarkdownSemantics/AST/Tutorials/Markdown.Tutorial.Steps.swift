import MarkdownAST
import Sources

extension Markdown.Tutorial {
    final class Steps: Markdown.BlockContainer<Markdown.BlockElement> {
        public var source: SourceReference<Markdown.Source>?

        private var list: [Step]

        init() {
            self.source = nil
            self.list = []
            super.init([])
        }

        override func emit(into binary: inout Markdown.BinaryEncoder) {
            super.emit(into: &binary)

            binary[.ol, { $0[.class] = "steps" }] {
                for step: Step in self.list {
                    step.emit(into: &$0)
                }
            }
        }

        override func traverse(with visit: (Markdown.BlockElement) throws -> ()) rethrows {
            try super.traverse(with: visit)
            for step: Step in self.list {
                try step.traverse(with: visit)
            }
        }
    }
}
extension Markdown.Tutorial.Steps: Markdown.BlockDirectiveType {
    func configure(option: Markdown.NeverOption, value _: Markdown.SourceString) {
    }

    func append(_ element: Markdown.BlockElement) {
        if  case let step as Markdown.Tutorial.Step = element {
            self.list.append(step)
        } else {
            self.elements.append(element)
        }
    }
}
