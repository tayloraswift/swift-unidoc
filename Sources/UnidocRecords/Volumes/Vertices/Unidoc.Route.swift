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
        let swift:Bool

        @inlinable internal
        init(shoot:Shoot, swift:Bool = true)
        {
            self.shoot = shoot
            self.swift = swift
        }
    }
}
extension Unidoc.Route
{
    @inlinable public static
    func bare(_ stem:Unidoc.Stem) -> Self
    {
        .init(shoot: .init(stem: stem, hash: nil), swift: true)
    }
}
extension Unidoc.Route
{
    @inlinable public
    var stem:Unidoc.Stem { self.shoot.stem }

    @inlinable public
    var hash:FNV24? { self.shoot.hash }
}
