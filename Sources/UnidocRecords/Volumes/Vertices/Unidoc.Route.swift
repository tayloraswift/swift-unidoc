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
