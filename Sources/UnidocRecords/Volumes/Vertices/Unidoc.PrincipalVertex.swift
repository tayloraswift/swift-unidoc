import FNV1
import Symbols
import UnidocAPI

extension Unidoc
{
    /// Abstracts over all vertex types that can be returned as a principal query output.
    /// Avoid storing large buffers of existentials of this type; use ``AnyVertex`` instead.
    public
    typealias PrincipalVertex = _UnidocPrincipalVertex
}
/// The name of this protocol is ``Unidoc.PrincipalVertex``.
public
protocol _UnidocPrincipalVertex:Identifiable<Unidoc.Scalar>
{
    var overview:Unidoc.Passage? { get }
    var details:Unidoc.Passage? { get }

    var route:Unidoc.Route { get }
    var shoot:Unidoc.Shoot { get }
    var stem:Unidoc.Stem { get }
    var hash:FNV24.Extended { get }

    var bias:Unidoc.Bias { get }
    var decl:Phylum.DeclFlags? { get }
}
extension Unidoc.PrincipalVertex
{
    @inlinable public
    var route:Unidoc.Route { .init(shoot: self.shoot) }

    @inlinable public
    var shoot:Unidoc.Shoot { .init(stem: self.stem) }
}
