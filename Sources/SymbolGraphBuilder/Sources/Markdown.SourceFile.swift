import MarkdownABI
import SymbolGraphLinker
import Symbols
import System
import URI

extension Markdown
{
    final
    class SourceFile:SPM.Resource<String>, Identifiable
    {
        let path:Symbol.File
        /// An identifier that can be used to link this file across package boundaries.
        /// Like ``name``, this identifier is only unique across a single file type, but
        /// unlike ``name``, it is unique across an entire build tree.
        let id:Symbol.Article

        private
        init(location:FilePath, path:Symbol.File, id:Symbol.Article)
        {
            self.path = path
            self.id = id

            super.init(location: location)
        }
    }
}
extension Markdown.SourceFile
{
    convenience
    init(location:FilePath,
        path:Symbol.File,
        in bundle:borrowing Symbol.Module)
    {
        let stem:Substring = path.last.prefix { $0 != "." }
        let name:String = .init(
            decoding: stem.utf8.map { URI.Path.Component.EncodingSet.contains($0) ? 0x2d : $0 },
            as: Unicode.ASCII.self)

        self.init(location: location, path: path, id: .init(bundle, name))
    }
}
extension Markdown.SourceFile:StaticTextFile
{
    /// The mangled stem of the filename. This string is case-sensitive, but has all
    /// url-incompatible characters replaced with hyphens (`-`).
    ///
    /// For example, the file `Getting Started.generated.md` would have the mangled stem
    /// `Getting-Started`.
    ///
    /// This identity is only unique within a single module, and only within a single
    /// file type.
    public
    var name:String { .init(self.id.name) }
}
