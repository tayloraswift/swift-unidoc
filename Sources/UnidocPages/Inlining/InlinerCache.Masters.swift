import Unidoc
import UnidocRecords

extension InlinerCache
{
    struct Masters
    {
        let principal:Unidoc.Scalar?
        private(set)
        var secondary:[Unidoc.Scalar: Volume.Vertex]

        init(
            principal:Unidoc.Scalar?,
            secondary:[Unidoc.Scalar: Volume.Vertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension InlinerCache.Masters
{
    mutating
    func add(_ masters:[Volume.Vertex])
    {
        for master:Volume.Vertex in masters where
            master.id != self.principal
        {
            self.secondary[master.id] = master
        }
    }
}
extension InlinerCache.Masters
{
    subscript(_ scalar:Unidoc.Scalar) -> Volume.Vertex?
    {
        self.principal == scalar ? nil : self.secondary[scalar]
    }
}
