import Sources
import SymbolGraphCompiler

struct MarkdownSource
{
    /// The absolute location of the markdown source within a larger source file,
    /// if known. If the markdown source was a standalone markdown file, this is
    /// ``SourceLocation zero``.
    let location:SourceLocation<Int32>?
    /// The unparsed markdown source text.
    let text:String

    init(location:SourceLocation<Int32>?, text:String)
    {
        self.location = location
        self.text = text
    }
}
extension MarkdownSource
{
    init(from comment:__shared Compiler.Doccomment, in file:Int32?)
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
