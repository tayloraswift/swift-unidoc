import Symbols

extension Unidoc
{
    @frozen public
    struct UplinkStatus:Equatable, Sendable
    {
        public
        let edition:Edition
        public
        let volume:Symbol.Volume
        public
        let hidden:Bool
        public
        let delta:SurfaceDelta?

        @inlinable public
        init(edition:Edition,
            volume:Symbol.Volume,
            hidden:Bool,
            delta:SurfaceDelta?)
        {
            self.edition = edition
            self.volume = volume
            self.hidden = hidden
            self.delta = delta
        }
    }
}
