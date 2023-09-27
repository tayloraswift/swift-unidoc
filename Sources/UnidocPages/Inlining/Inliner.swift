import HTML
import LexicalPaths
import MarkdownABI
import ModuleGraphs
import Signatures
import Unidoc
import UnidocDB
import UnidocRecords

final
class Inliner
{
    /// Shared outlines, valid for the overview and details passages.
    var outlines:[Volume.Outline]

    private
    var cache:InlinerCache

    let repo:PackageRepo?

    private
    init(cache:InlinerCache, repo:PackageRepo?)
    {
        self.outlines = []
        self.cache = cache
        self.repo = repo
    }
}
extension Inliner
{
    var vertices:InlinerCache.Vertices
    {
        _read   { yield  self.cache.vertices }
        _modify { yield &self.cache.vertices }
    }
    var names:InlinerCache.Names
    {
        _read   { yield  self.cache.names }
        _modify { yield &self.cache.names }
    }
}
extension Inliner
{
    convenience
    init(principal scalar:Unidoc.Scalar, names:Volume.Meta, repo:PackageRepo?)
    {
        self.init(cache: .init(
                vertices: .init(principal: scalar),
                names: .init(principal: names)),
            repo: repo)
    }
    convenience
    init(principal names:Volume.Meta, repo:PackageRepo?)
    {
        self.init(cache: .init(
                vertices: .init(principal: nil),
                names: .init(principal: names)),
            repo: repo)
    }
}
extension Inliner
{
    func passage(overview passage:Volume.Passage) -> Passage
    {
        .init(self, bytecode: passage.markdown, outlines: passage.outlines)
    }
    func passage(_ bytecode:MarkdownBytecode) -> Passage
    {
        //  We need to use the shared outlines, and not the array from the passage
        //  record, lest we make a frameshift indexing error.
        .init(self, bytecode: bytecode, outlines: self.outlines)
    }
    func code(_ snippet:Signature<Unidoc.Scalar?>.Expanded) -> Code
    {
        .init(self, bytecode: snippet.bytecode, scalars: snippet.scalars)
    }
}
extension Inliner
{
    func card(_ scalar:Unidoc.Scalar) -> Card?
    {
        self.cache[scalar].map
        {
            .init(overview: $0.overview.map(self.passage(overview:)),
                master: $0,
                target: $1)
        }
    }
}
extension Inliner
{
    func list(members:[Volume.Link], to list:inout HTML.ContentEncoder)
    {
        for member:Volume.Link in members
        {
            switch member
            {
            case .scalar(let scalar):
                list ?= self.card(scalar)

            case .text(let text):
                list[.li] { $0[.span] { $0[.code] = text } }
            }
        }
    }
}
extension Inliner
{
    func vectorLink<Display, Scalars>(
        components display:Display,
        to scalars:Scalars) -> VectorLink<Display, Scalars>
        where Scalars:Sequence<Unidoc.Scalar>
    {
        .init(self, display: display, scalars: scalars)
    }
}
extension Inliner
{
    func link(module:Unidoc.Scalar) -> HTML.Link<ModuleIdentifier>?
    {
        self.cache[culture: module].map
        {
            .init(display: $0.module.id, target: $1)
        }
    }
    func link(decl:Unidoc.Scalar) -> HTML.Link<String>?
    {
        self.cache[decl: decl].map
        {
            let path:UnqualifiedPath? = .init(splitting: $0.stem)
            return .init(display: path?.description ?? "", target: $1)
        }
    }
    func link(file:Unidoc.Scalar, line:Int? = nil) -> HTML.SourceLink?
    {
        if  let origin:Volume.Origin = self.repo?.origin,
            let refname:String = self.names[file.zone]?.refname,
            let file:Volume.Vertex.File = self.vertices[file]?.file,
            let blob:String = origin.blob(refname: refname, file: file.symbol)
        {
            return .init(
                file: file.symbol.last,
                line: line,
                target: line.map { "\(blob)#L\($0 + 1)" } ?? blob)
        }
        else
        {
            return nil
        }
    }
}
extension Inliner
{
    func url(_ scalar:Unidoc.Scalar) -> String?
    {
        self.cache[scalar]?.url
    }
}
