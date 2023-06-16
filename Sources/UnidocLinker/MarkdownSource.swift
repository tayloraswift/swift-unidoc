import Sources
import UnidocCompiler

struct MarkdownSource
{
    let location:SourceLocation<Int32>?
    let text:String

    init(location:SourceLocation<Int32>?, text:String)
    {
        self.location = location
        self.text = text
    }
}
extension MarkdownSource
{
    init(from article:__shared StandaloneArticle)
    {
        self.init(location: .init(position: .zero, file: article.file), text: article.text)
    }

    init(from comment:__shared Compiler.Documentation.Comment, in file:Int32?)
    {
        if  let position:SourcePosition = comment.start,
            let file:Int32
        {
            self.init(location: .init(position: position, file: file), text: comment.text)
        }
        else
        {
            self.init(location: nil, text: comment.text)
        }
    }
}
