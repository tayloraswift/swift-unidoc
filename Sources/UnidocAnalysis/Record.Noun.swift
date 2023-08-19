import FNV1
import UnidocRecords

extension Record.Noun
{
    @frozen public
    enum Race:UInt8, Equatable, Hashable, Sendable
    {
        case culture = 0x01
        case package = 0x02
    }
}
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
