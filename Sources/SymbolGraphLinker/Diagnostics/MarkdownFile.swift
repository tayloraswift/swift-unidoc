import ModuleGraphs
import Symbols
import URI

@frozen public
struct MarkdownFile:Equatable, Sendable
{
    /// An identifier that can be used to link this file across package boundaries.
    /// Like ``id``, this identifier is only unique across a single file type, but
    /// unlike ``id``, it is unique across an entire build tree.
    public
    let symbol:Symbol.Article
    public
    let path:Symbol.File
    public
    let text:String

    private
    init(symbol:Symbol.Article, path:Symbol.File, text:String)
    {
        self.symbol = symbol
        self.path = path
        self.text = text
    }
}
extension MarkdownFile
{
    public
    init(bundle:__shared ModuleIdentifier, path:__owned Symbol.File, text:__owned String)
    {
        let stem:Substring = path.last.prefix { $0 != "." }
        let id:String = .init(
            decoding: stem.utf8.map { URI.Path.Component.EncodingSet.contains($0) ? 0x2d : $0 },
            as: Unicode.ASCII.self)

        self.init(symbol: .init(bundle, id), path: path, text: text)
    }
}
extension MarkdownFile:Identifiable
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
    var id:Substring { self.symbol.name }
}
