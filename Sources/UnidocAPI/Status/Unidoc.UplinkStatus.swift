import Symbols

extension Unidoc
{
    @frozen public
    struct UplinkStatus:Equatable, Sendable
    {
        public
        let edition:Edition
        public
        let volume:Symbol.Edition
        public
        let hidden:Bool
        public
        let delta:SitemapDelta?

        @inlinable public
        init(edition:Edition,
            volume:Symbol.Edition,
            hidden:Bool,
            delta:SitemapDelta?)
        {
            self.edition = edition
            self.volume = volume
            self.hidden = hidden
            self.delta = delta
        }
    }
}
