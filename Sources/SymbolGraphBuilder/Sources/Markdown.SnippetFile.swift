import MarkdownABI
import SymbolGraphLinker
import Symbols
import System

extension Markdown
{
    final
    class SnippetFile:SPM.ResourceFile<String>
    {
        let path:Symbol.File
        let name:String

        init(location:FilePath, path:Symbol.File, name:String)
        {
            self.path = path
            self.name = name

            super.init(location: location)
        }
    }
}
extension Markdown.SnippetFile:Identifiable
{
    var id:Symbol.Module { .init(mangling: self.name) }
}
extension Markdown.SnippetFile:StaticTextFile
{
}
