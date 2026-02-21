import Symbols

extension SyntaxClassificationCursor {
    struct Span {
        let color: Markdown.Bytecode.Context?
        let usr: Symbol.USR?
        let end: Int

        init(color: Markdown.Bytecode.Context?, usr: Symbol.USR?, end: Int) {
            self.color = color
            self.usr = usr
            self.end = end
        }
    }
}
