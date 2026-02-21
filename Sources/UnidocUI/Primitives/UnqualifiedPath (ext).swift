import HTML
import LexicalPaths
import MarkdownRendering

extension UnqualifiedPath: HTML.OutputStreamable {
    @inlinable public static func += (html: inout HTML.ContentEncoder, self: Self) {
        var first: Bool = true
        for component: String in self {
            if  first {
                first = false
            } else {
                html += "."
            }

            html[.span] { $0.highlight = .identifier } = component
        }
    }
}
