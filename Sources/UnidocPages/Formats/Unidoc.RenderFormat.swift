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

        @inlinable public
        init(assets:Assets, accept:AcceptType = .application(.html))
        {
            self.accept = accept
            self.assets = assets
        }
    }
}
