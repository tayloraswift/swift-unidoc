import MarkdownABI
import SymbolGraphLinker
import Symbols
import System
import URI

extension SPM
{
    final
    class SourceFile:SPM.Resource<String>
    {
        let name:String

        init(location:FilePath, path:Symbol.File, name:String)
        {
            self.name = name
            super.init(location: location, path: path)
        }
    }
}
extension SPM.SourceFile
{
    /// Mangles the stem of the filename. This string is case-sensitive, but has all
    /// url-incompatible characters replaced with hyphens (`-`).
    ///
    /// For example, the file `Getting Started.generated.md` would have the mangled stem
    /// `Getting-Started`.
    ///
    /// This identity is only unique within a single module, and only within a single
    /// file type.
    convenience
    init(location:FilePath, root:borrowing SPM.PackageRoot)
    {
        let path:Symbol.File = root.rebase(location)
        let stem:Substring = path.last.prefix { $0 != "." }
        let name:String = .init(
            decoding: stem.utf8.map { URI.Path.Component.EncodingSet.contains($0) ? 0x2d : $0 },
            as: Unicode.ASCII.self)

        self.init(location: location, path: path, name: name)
    }
}
extension SPM.SourceFile:StaticTextFile
{
}
