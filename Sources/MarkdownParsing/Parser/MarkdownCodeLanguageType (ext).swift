import MarkdownABI
import MarkdownTrees

extension MarkdownCodeLanguageType
{
    func attach(to code:String) -> MarkdownBlock
    {
        MarkdownBlock.Code<Self>.init(language: self, text: code)
    }
}
