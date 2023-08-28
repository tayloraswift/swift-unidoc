import FNV1
import UnidocRecords

extension Volume.Shoot
{
    public
    init(stem path:__shared ArraySlice<String>, hash:__owned FNV24? = nil)
    {
        self.init(stem: .init(path: path), hash: hash)
    }
}
