import Unidoc
import UnidocRecords

struct MasterIndex
{
    let principal:Unidoc.Scalar?
    private(set)
    var secondary:[Unidoc.Scalar: Record.Master]

    init(
        principal:Unidoc.Scalar?,
        secondary:[Unidoc.Scalar: Record.Master] = [:])
    {
        self.principal = principal
        self.secondary = secondary
    }
}
extension MasterIndex
{
    mutating
    func add(_ masters:[Record.Master])
    {
        for master:Record.Master in masters where
            master.id != self.principal
        {
            self.secondary[master.id] = master
        }
    }
}
extension MasterIndex
{
    subscript(_ scalar:Unidoc.Scalar) -> Record.Master?
    {
        self.principal == scalar ? nil : self.secondary[scalar]
    }
}
