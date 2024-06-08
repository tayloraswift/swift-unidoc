import MarkdownABI

extension Markdown.SnippetSlice
{
    var text:String
    {
        var text:String = ""
        for fragment:Markdown.SnippetFragment in self.code
        {
            text += String.init(decoding: self.utf8[fragment.range], as: UTF8.self)
        }
        return text
    }
}
