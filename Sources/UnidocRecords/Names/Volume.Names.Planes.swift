import Unidoc

extension Volume.Names
{
    @frozen public
    struct Planes
    {
        public
        let zone:Unidoc.Zone

        @inlinable public
        init(zone:Unidoc.Zone)
        {
            self.zone = zone
        }
    }
}
extension Volume.Names.Planes
{
    @inlinable public
    var min:Unidoc.Scalar { self.zone.min }

    @inlinable public
    var article:Unidoc.Scalar { self.zone + (0 * .article) }
    @inlinable public
    var file:Unidoc.Scalar { self.zone + (0 * .file) }

    @inlinable public
    var autogroup:Unidoc.Scalar { self.zone + (0 * .autogroup) }
    @inlinable public
    var `extension`:Unidoc.Scalar { self.zone + (0 * .extension) }
    @inlinable public
    var topic:Unidoc.Scalar { self.zone + (0 * .topic) }

    @inlinable public
    var max:Unidoc.Scalar { self.zone.max }
}
