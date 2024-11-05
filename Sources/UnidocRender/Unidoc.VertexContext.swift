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
        var vertices:Table { get }

        /// Returns the metadata document for the principal volume of the associated page.
        var volume:VolumeMetadata { get }
        var media:PackageMedia { get }
        var repo:PackageRepo? { get }

        subscript(package id:Package) -> PackageMetadata? { get }

        /// Returns the metadata document for the specified volume, if available.
        subscript(volume:Edition) -> VolumeMetadata? { get }

        /// Returns the vertex document for the specified vertex and its URL, if available.
        subscript(vertex id:Scalar) -> LinkReference<AnyVertex>? { get }

        subscript(culture id:Scalar) -> LinkReference<CultureVertex>? { get }
        subscript(article id:Scalar) -> LinkReference<ArticleVertex>? { get }
        subscript(decl id:Scalar) -> LinkReference<DeclVertex>? { get }
    }
}
extension Unidoc.VertexContext
{
    @inlinable public
    subscript(culture id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.CultureVertex>
    {
        get throws
        {
            guard let vertex:Unidoc.LinkReference<Unidoc.CultureVertex> = self[culture: id]
            else
            {
                throw Unidoc.LinkReferenceError<Unidoc.CultureVertex>.missing(id)
            }
            return vertex
        }
    }

    @inlinable public
    subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>
    {
        get throws
        {
            guard let vertex:Unidoc.LinkReference<Unidoc.ArticleVertex> = self[article: id]
            else
            {
                throw Unidoc.LinkReferenceError<Unidoc.ArticleVertex>.missing(id)
            }
            return vertex
        }
    }

    @inlinable public
    subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>
    {
        get throws
        {
            guard let vertex:Unidoc.LinkReference<Unidoc.DeclVertex> = self[decl: id]
            else
            {
                throw Unidoc.LinkReferenceError<Unidoc.DeclVertex>.missing(id)
            }
            return vertex
        }
    }
}
