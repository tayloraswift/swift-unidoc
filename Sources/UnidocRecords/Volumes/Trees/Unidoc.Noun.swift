import FNV1

extension Unidoc
{
    @frozen public
    struct Noun:Equatable, Hashable, Sendable
    {
        public
        let shoot:Shoot
        public
        let style:Style

        @inlinable public
        init(shoot:Shoot, style:Style)
        {
            self.shoot = shoot
            self.style = style
        }
    }
}
extension Unidoc.Noun
{
    @inlinable public
    init(stem:Unidoc.Stem, hash:FNV24? = nil, text:String)
    {
        self.init(shoot: .init(stem: stem, hash: hash), style: .text(text))
    }
    @inlinable public
    init(stem:Unidoc.Stem, hash:FNV24? = nil, from citizenship:Volume.Citizenship = .culture)
    {
        self.init(shoot: .init(stem: stem, hash: hash), style: .stem(citizenship))
    }
}
