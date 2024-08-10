import FNV1
import UCF

extension UCF.Selector
{
    func with(hash:FNV24) -> UCF.Selector
    {
        .init(base: self.base, path: self.path, suffix: .hash(hash))
    }
}
