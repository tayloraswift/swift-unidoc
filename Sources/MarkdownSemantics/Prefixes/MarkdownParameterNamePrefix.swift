import Codelinks
import MarkdownTrees

struct MarkdownParameterNamePrefix
{
    let identifier:Codelink.Identifier

    init(identifier:Codelink.Identifier)
    {
        self.identifier = identifier
    }
}
extension MarkdownParameterNamePrefix:MarkdownSemanticPrefix
{
    /// If a parameter name uses formatting, the formatting must apply
    /// to the entire pattern.
    static
    var radius:Int { 2 }

    init?(from elements:__shared [MarkdownTree.InlineBlock])
    {
        if  elements.count == 1,
            let identifier:Codelink.Identifier = .init(elements[0].text)
        {
            self.init(identifier: identifier)
        }
        else
        {
            return nil
        }
    }
}
