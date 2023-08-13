import FNV1
import UnidocRecords

extension Records.TypeLevels
{
    struct Node
    {
        let shoot:Record.Shoot
        var nest:[Node]

        init(shoot:Record.Shoot, nest:[Node] = [])
        {
            self.shoot = shoot
            self.nest = nest
        }
    }
}
extension Records.TypeLevels.Node
{
    /// Sorts all the nested nodes within this node’s ``nest`` by last stem component.
    mutating
    func sort()
    {
        self.nest.sort { $0.shoot.stem.last < $1.shoot.stem.last }
    }
}
