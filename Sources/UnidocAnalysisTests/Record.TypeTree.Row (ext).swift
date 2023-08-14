import FNV1
import UnidocRecords

extension Record.TypeTree.Row
{
    init(stem:Record.Stem, hash:FNV24?, top:Bool = false)
    {
        self.init(shoot: .init(stem: stem, hash: hash), top: top)
    }
}
