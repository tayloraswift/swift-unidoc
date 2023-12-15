import Media

extension Swiftinit
{
    @frozen public
    struct RenderFormat
    {
        public
        let assets:Assets
        public
        let accept:AcceptType
        public
        let secure:Bool

        @inlinable public
        init(
            assets:Assets,
            accept:AcceptType = .application(.html),
            secure:Bool = true)
        {
            self.accept = accept
            self.assets = assets
            self.secure = secure
        }
    }
}
