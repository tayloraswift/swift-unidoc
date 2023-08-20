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
        let same:Race?

        @inlinable internal
        init(shoot:Record.Shoot, same:Race? = nil)
        {
            self.shoot = shoot
            self.same = same
        }
    }
}
extension Record.Noun
{
    @inlinable public
    init(stem:Record.Stem, hash:FNV24? = nil, same race:Race? = nil)
    {
        self.init(shoot: .init(stem: stem, hash: hash), same: race)
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
