import HTML
import Unidoc
import UnidocRecords

public
protocol VersionedPageContext:AnyObject
{
    func vector<Display, Vector>(_ vector:Vector,
        display:Display) -> HTML.VectorLink<Display, Vector>
        where Vector:Sequence<Unidoc.Scalar>

    func url(_ scalar:Unidoc.Scalar) -> String?

    /// Returns the principal volume metadata for the associated page.
    var volume:Volume.Meta { get }

    /// Returns the volume metadata for the specified edition, if available.
    subscript(edition:Unidoc.Edition) -> Volume.Meta? { get }
}
