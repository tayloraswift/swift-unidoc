import FNV1
import UnidocRecords

extension Record
{
    @frozen public
    struct Noun:Equatable, Hashable, Sendable
    {
        public
        let shoot:Record.Shoot
        public
        let same:Locality?

        @inlinable internal
        init(shoot:Record.Shoot, same locality:Locality? = nil)
        {
            self.shoot = shoot
            self.same = locality
        }
    }
}
extension Record.Noun
{
    @inlinable public
    init(stem:Record.Stem, hash:FNV24? = nil, same locality:Locality? = nil)
    {
        self.init(shoot: .init(stem: stem, hash: hash), same: locality)
    }
}
extension Record.Noun:CustomDebugStringConvertible
{
    public
    var debugDescription:String
    {
        "\(self.shoot)\(self.same.map { " (same \($0))" } ?? "")"
    }
}
