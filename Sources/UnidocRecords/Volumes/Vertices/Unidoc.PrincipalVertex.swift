import FNV1
import Symbols
import UnidocAPI

extension Unidoc
{
    /// Abstracts over all vertex types that can be returned as a principal query output.
    /// Avoid storing large buffers of existentials of this type; use ``AnyVertex`` instead.
    public
    protocol PrincipalVertex:Identifiable<Unidoc.Scalar>
    {
        var overview:Passage? { get }
        var details:Passage? { get }

        var route:Route { get }
        var shoot:Shoot { get }
        var stem:Stem { get }
        var hash:FNV24.Extended { get }

        var bias:Bias { get }
        var decl:Phylum.DeclFlags? { get }
    }
}
extension Unidoc.PrincipalVertex
{
    @inlinable public
    var outlinesConcatenated:[Unidoc.Outline]
    {
        switch (self.overview, self.details)
        {
        case (let overview?, let details?): return overview.outlines + details.outlines
        case (let overview?, nil):          return overview.outlines
        case (nil, let details?):           return details.outlines
        case (nil, nil):                    return []
        }
    }
}
extension Unidoc.PrincipalVertex
{
    @inlinable public
    var route:Unidoc.Route { .init(shoot: self.shoot) }

    @inlinable public
    var shoot:Unidoc.Shoot { .init(stem: self.stem) }
}
