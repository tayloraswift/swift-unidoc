import HTML
import LexicalPaths
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
    /// Returns the metadata document for the principal volume of the associated page.
    var volume:Unidoc.VolumeMetadata { get }
    var origin:Unidoc.PackageOrigin? { get }

    /// Returns the metadata document for the specified volume, if available.
    subscript(volume:Unidoc.Edition) -> Unidoc.VolumeMetadata? { get }
    /// Returns the vertex document for the specified vertex, if available.
    subscript(vertex:Unidoc.Scalar) -> Unidoc.AnyVertex? { get }

    /// Returns the vertex document for the specified vertex and its URL, if available.
    ///
    /// The URL could be nil if the vertex’s native volume could not be loaded, or if the URL
    /// would point back to the current page.
    subscript(vertex id:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, url:String?)? { get }

    subscript(culture id:Unidoc.Scalar) -> (vertex:Unidoc.CultureVertex, url:String?)? { get }
    subscript(article id:Unidoc.Scalar) -> (vertex:Unidoc.ArticleVertex, url:String?)? { get }
    subscript(decl id:Unidoc.Scalar) -> (vertex:Unidoc.DeclVertex, url:String?)? { get }

    subscript(file id:Unidoc.Scalar) -> Unidoc.FileVertex? { get }
}
