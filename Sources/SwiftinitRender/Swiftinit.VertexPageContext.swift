import HTML
import MarkdownABI
import MarkdownRendering
import Symbols
import Unidoc
import UnidocRecords

extension Swiftinit
{
    public
    typealias VertexPageContext = _SwiftinitVertexPageContext
}

public
protocol _SwiftinitVertexPageContext:AnyObject
{
    func link(article:Unidoc.Scalar) -> HTML.Link<MarkdownBytecode.SafeView>?

    func link(module:Unidoc.Scalar) -> HTML.Link<Symbol.Module>?

    func vector<Display, Vector>(_ vector:Vector,
        display:Display) -> HTML.VectorLink<Display, Vector>?
        where Vector:Collection<Unidoc.Scalar>

    func url(_ scalar:Unidoc.Scalar) -> String?

    /// Returns the principal volume metadata for the associated page.
    var volume:Unidoc.VolumeMetadata { get }

    /// Returns the volume metadata for the specified edition, if available.
    subscript(edition:Unidoc.Edition) -> Unidoc.VolumeMetadata? { get }
}
