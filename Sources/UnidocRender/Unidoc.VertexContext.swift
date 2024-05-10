import HTML
import Symbols
import UnidocRecords

extension Unidoc
{
    public
    protocol VertexContext:AnyObject
    {
        associatedtype Tooltips:HTML.OutputStreamable
        associatedtype Table:VertexContextTable

        init(canonical:CanonicalVersion?,
            principal:VolumeMetadata,
            secondary:borrowing [VolumeMetadata],
            packages:borrowing [PackageMetadata],
            vertices:Table)

        var canonical:CanonicalVersion? { get }
        var tooltips:Tooltips? { get }

        /// Returns the metadata document for the principal volume of the associated page.
        var volume:VolumeMetadata { get }
        var media:PackageMedia? { get }
        var repo:PackageRepo? { get }

        subscript(package id:Package) -> PackageMetadata? { get }

        /// Returns the metadata document for the specified volume, if available.
        subscript(volume:Edition) -> VolumeMetadata? { get }
        /// Returns the vertex document for the specified vertex, if available.
        subscript(vertex:Scalar) -> AnyVertex? { get }

        /// Returns the vertex document for the specified vertex and its URL, if available.
        subscript(vertex id:Scalar) -> LinkReference<AnyVertex>? { get }

        subscript(culture id:Scalar) -> LinkReference<CultureVertex>? { get }
        subscript(article id:Scalar) -> LinkReference<ArticleVertex>? { get }
        subscript(decl id:Scalar) -> LinkReference<DeclVertex>? { get }

        subscript(file id:Scalar) -> FileVertex? { get }
    }
}
