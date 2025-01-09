import MarkdownAST

extension Markdown
{
    struct BlockDirectiveUnexpectedOptionError:Error
    {
        let option:String
        let block:String
    }
}
extension Markdown.BlockDirectiveUnexpectedOptionError:CustomStringConvertible
{
    var description:String
    {
        "unexpected option '\(self.option)' for block directive '@\(self.block)'"
    }
}
