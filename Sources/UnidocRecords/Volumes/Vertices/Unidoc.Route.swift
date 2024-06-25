import FNV1
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct Route:Hashable, Equatable, Sendable
    {
        public
        let shoot:Shoot
        public
        let cdecl:Bool

        @inlinable internal
        init(shoot:Shoot, cdecl:Bool = false)
        {
            self.shoot = shoot
            self.cdecl = cdecl
        }
    }
}
extension Unidoc.Route
{
    @inlinable public static
    func bare(_ stem:Unidoc.Stem) -> Self
    {
        .init(shoot: .init(stem: stem, hash: nil), cdecl: false)
    }
}
extension Unidoc.Route
{
    @inlinable public
    var stem:Unidoc.Stem { self.shoot.stem }

    @inlinable public
    var hash:FNV24? { self.shoot.hash }
}
