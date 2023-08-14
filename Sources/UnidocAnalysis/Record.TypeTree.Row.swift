import FNV1
import UnidocRecords

extension Record.TypeTree
{
    @frozen public
    struct Row:Equatable, Hashable, Sendable
    {
        public
        let shoot:Record.Shoot
        public
        let top:Bool

        @inlinable public
        init(shoot:Record.Shoot, top:Bool = false)
        {
            self.shoot = shoot
            self.top = top
        }
    }
}
extension Record.TypeTree.Row
{
    @inlinable public
    init(stem:Record.Stem, hash:FNV24? = nil, top:Bool = false)
    {
        self.init(shoot: .init(stem: stem, hash: hash), top: top)
    }
}
extension Record.TypeTree.Row
{
    /// Returns 1 if this is a top-level row, otherwise returns the ``Record.Stem depth``
    /// of the ``shoot``’s stem.
    @inlinable public
    var depth:Int { self.top ? 1 : self.shoot.stem.depth }
}
