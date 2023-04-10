import Codelinks
import MarkdownTrees

struct MarkdownParameterNamePrefix
{
    let name:String

    init(name:String)
    {
        self.name = name
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
            self.init(name: identifier.unencased)
        }
        else
        {
            return nil
        }
    }
}
