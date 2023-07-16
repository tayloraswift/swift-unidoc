import Unidoc
import UnidocRecords

extension Inliner
{
    struct Masters
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
}
extension Inliner.Masters
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
extension Inliner.Masters
{
    subscript(_ scalar:Unidoc.Scalar) -> Record.Master?
    {
        self.principal == scalar ? nil : self.secondary[scalar]
    }
}
