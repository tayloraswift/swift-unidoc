import FNV1
import UnidocRecords

extension Volume
{
    @frozen public
    struct Noun:Equatable, Hashable, Sendable
    {
        public
        let shoot:Volume.Shoot
        public
        let same:Locality?

        @inlinable internal
        init(shoot:Volume.Shoot, same locality:Locality? = nil)
        {
            self.shoot = shoot
            self.same = locality
        }
    }
}
extension Volume.Noun
{
    @inlinable public
    init(stem:Volume.Stem, hash:FNV24? = nil, same locality:Locality? = nil)
    {
        self.init(shoot: .init(stem: stem, hash: hash), same: locality)
    }
}
extension Volume.Noun:CustomDebugStringConvertible
{
    public
    var debugDescription:String
    {
        "\(self.shoot)\(self.same.map { " (same \($0))" } ?? "")"
    }
}
