import MarkdownABI
import MarkdownAST

extension Markdown.CodeLanguageType
{
    func attach(to code:String) -> Markdown.BlockElement
    {
        Markdown.BlockCode<Self>.init(language: self, text: code)
    }
}
