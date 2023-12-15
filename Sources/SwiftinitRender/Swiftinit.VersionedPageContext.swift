import HTML
import Unidoc
import UnidocRecords

extension Swiftinit
{
    public
    typealias VersionedPageContext = _SwiftinitVersionedPageContext
}

public
protocol _SwiftinitVersionedPageContext:AnyObject
{
    func vector<Display, Vector>(_ vector:Vector,
        display:Display) -> HTML.VectorLink<Display, Vector>
        where Vector:Sequence<Unidoc.Scalar>

    func url(_ scalar:Unidoc.Scalar) -> String?

    /// Returns the principal volume metadata for the associated page.
    var volume:Unidoc.VolumeMetadata { get }

    /// Returns the volume metadata for the specified edition, if available.
    subscript(edition:Unidoc.Edition) -> Unidoc.VolumeMetadata? { get }
}
