import Media

extension Unidoc
{
    @frozen public
    struct RenderFormat
    {
        @usableFromInline
        let assets:Assets
        @usableFromInline
        let accept:AcceptType
        @usableFromInline
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
