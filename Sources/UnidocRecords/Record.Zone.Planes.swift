import Unidoc

extension Record.Zone
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
extension Record.Zone.Planes
{
    @inlinable public
    var min:Unidoc.Scalar { self.zone.min }

    @inlinable public
    var module:Unidoc.Scalar { self.zone + (0 * .module) }
    @inlinable public
    var `extension`:Unidoc.Scalar { self.zone + (0 * .extension) }
    @inlinable public
    var file:Unidoc.Scalar { self.zone + (0 * .file) }
    @inlinable public
    var article:Unidoc.Scalar { self.zone + (0 * .article) }

    @inlinable public
    var max:Unidoc.Scalar { self.zone.max }
}
