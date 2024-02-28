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
        let detail:Bool

        @inlinable internal
        init(shoot:Shoot, detail:Bool = false)
        {
            self.shoot = shoot
            self.detail = detail
        }
    }
}
extension Unidoc.Route
{
    @inlinable public static
    func bare(_ stem:Unidoc.Stem) -> Self
    {
        .init(shoot: .init(stem: stem, hash: nil), detail: false)
    }
}
extension Unidoc.Route
{
    @inlinable public
    var stem:Unidoc.Stem { self.shoot.stem }

    @inlinable public
    var hash:FNV24? { self.shoot.hash }
}
