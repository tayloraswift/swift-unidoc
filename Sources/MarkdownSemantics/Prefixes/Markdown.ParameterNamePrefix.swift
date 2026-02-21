import MarkdownAST
import UCF

extension Markdown {
    /// A `ParameterNamePrefix` appears in a list item that begins with `- name:`, where *name*
    /// is the name of a parameter.
    ///
    /// This prefix should only appear inside a ``KeywordPrefix/parameters`` block. Its
    /// top-level analogue is ``ParameterPrefix``.
    struct ParameterNamePrefix {
        let name: String

        init(name: String) {
            self.name = name
        }
    }
}
extension Markdown.ParameterNamePrefix: Markdown.SemanticPrefix {
    /// If a parameter name uses formatting, the formatting must apply
    /// to the entire pattern.
    static var radius: Int { 2 }

    init?(from elements: __shared [Markdown.InlineElement]) {
        if  elements.count == 1 {
            //  Don’t attempt to validate the identifier for disallowed characters,
            //  this is the wrong place for that.
            self.init(name: elements[0].text)
        } else {
            return nil
        }
    }
}
