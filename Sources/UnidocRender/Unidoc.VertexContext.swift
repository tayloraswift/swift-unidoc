import HTML
import LexicalPaths
import MarkdownABI
import MarkdownRendering
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc
{
    public
    protocol VertexContext:AnyObject
    {
        init(canonical:CanonicalVersion?, vertices:Vertices, volumes:Volumes, repo:PackageRepo?)

        var canonical:CanonicalVersion? { get }
        /// Returns the metadata document for the principal volume of the associated page.
        var volume:VolumeMetadata { get }
        var repo:PackageRepo? { get }

        /// Returns the metadata document for the specified volume, if available.
        subscript(volume:Unidoc.Edition) -> VolumeMetadata? { get }
        /// Returns the vertex document for the specified vertex, if available.
        subscript(vertex:Unidoc.Scalar) -> AnyVertex? { get }

        /// Returns the vertex document for the specified vertex and its URL, if available.
        subscript(vertex id:Unidoc.Scalar) -> LinkReference<AnyVertex>? { get }

        subscript(culture id:Unidoc.Scalar) -> LinkReference<CultureVertex>? { get }
        subscript(article id:Unidoc.Scalar) -> LinkReference<ArticleVertex>? { get }
        subscript(decl id:Unidoc.Scalar) -> LinkReference<DeclVertex>? { get }

        subscript(file id:Unidoc.Scalar) -> FileVertex? { get }
    }
}
