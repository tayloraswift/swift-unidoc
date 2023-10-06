import FNV1

extension Volume
{
    @frozen public
    struct Noun:Equatable, Hashable, Sendable
    {
        public
        let shoot:Volume.Shoot
        public
        let style:Style

        @inlinable public
        init(shoot:Volume.Shoot, style:Style)
        {
            self.shoot = shoot
            self.style = style
        }
    }
}
extension Volume.Noun
{
    @inlinable public
    init(stem:Volume.Stem, hash:FNV24? = nil, text:String)
    {
        self.init(shoot: .init(stem: stem, hash: hash), style: .text(text))
    }
    @inlinable public
    init(stem:Volume.Stem, hash:FNV24? = nil, from citizenship:Volume.Citizenship = .culture)
    {
        self.init(shoot: .init(stem: stem, hash: hash), style: .stem(citizenship))
    }
}
