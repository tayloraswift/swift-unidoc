import FNV1
import Symbols
import UnidocRecords

extension Selector
{
    @frozen public
    struct Master:Equatable, Hashable, Sendable
    {
        public
        var planes:Planes

        public
        var stem:Record.Stem
        public
        var hash:FNV24?

        private
        init(planes:Planes, stem:Record.Stem, hash:FNV24?)
        {
            self.planes = planes
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Selector.Master
{
    public
    init(planes:__shared Selector.Planes,
        stem path:__shared ArraySlice<String>,
        hash:__owned FNV24? = nil)
    {
        self.init(planes: planes, stem: .init(path: path), hash: hash)
    }
}
