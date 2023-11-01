import Codelinks
import MarkdownAST

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

    init?(from elements:__shared [MarkdownInline.Block])
    {
        if  elements.count == 1
        {
            //  Don’t attempt to validate the identifier for disallowed characters,
            //  this is the wrong place for that.
            self.init(name: elements[0].text)
        }
        else
        {
            return nil
        }
    }
}
