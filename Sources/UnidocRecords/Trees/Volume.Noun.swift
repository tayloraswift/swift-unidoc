import FNV1

extension Volume
{
    @frozen public
    struct Noun:Equatable, Hashable, Sendable
    {
        public
        let shoot:Volume.Shoot
        public
        let from:Citizenship

        @inlinable public
        init(shoot:Volume.Shoot, from citizenship:Citizenship)
        {
            self.shoot = shoot
            self.from = citizenship
        }
    }
}
extension Volume.Noun
{
    @inlinable public
    init(stem:Volume.Stem, hash:FNV24? = nil, from citizenship:Volume.Citizenship = .culture)
    {
        self.init(shoot: .init(stem: stem, hash: hash), from: citizenship)
    }
}
extension Volume.Noun:CustomDebugStringConvertible
{
    public
    var debugDescription:String
    {
        "\(self.shoot) (from \(self.from))"
    }
}
