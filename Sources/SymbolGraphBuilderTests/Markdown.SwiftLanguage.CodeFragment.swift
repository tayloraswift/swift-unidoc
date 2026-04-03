import MarkdownABI
import Symbols

extension Markdown.SwiftLanguage {
    struct CodeFragment: Equatable {
        let token: String
        let color: Markdown.Bytecode.Context?
        let usr: Symbol.USR?

        init(
            token: String,
            color: Markdown.Bytecode.Context? = nil,
            usr: Symbol.USR? = nil
        ) {
            self.token = token
            self.color = color
            self.usr = usr
        }
    }
}
extension Markdown.SwiftLanguage.CodeFragment: CustomStringConvertible {
    var description: String {
        """
        ['\(self.token)'\
        \(self.color.map { ", \($0.highlight)" } ?? "")\
        \(self.usr.map { "\($0)" } ?? "")]
        """
    }
}
