import FNV1
import UnidocRecords

extension Record.TypeTree
{
    @frozen public
    struct Row:Equatable, Hashable, Sendable
    {
        public
        let stem:Record.Stem
        public
        let hash:FNV24?
        public
        let top:Bool

        @inlinable public
        init(stem:Record.Stem, hash:FNV24? = nil, top:Bool = false)
        {
            self.stem = stem
            self.hash = hash
            self.top = top
        }
    }
}
extension Record.TypeTree.Row
{
    @inlinable public
    init(node:Record.IndexNode, top:Bool = false)
    {
        self.init(stem: node.stem, hash: node.hash, top: top)
    }

    @inlinable public
    var node:Record.IndexNode
    {
        .init(stem: self.stem, hash: self.hash)
    }
}
