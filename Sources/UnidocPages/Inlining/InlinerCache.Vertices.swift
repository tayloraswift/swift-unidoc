import Unidoc
import UnidocRecords

extension InlinerCache
{
    struct Vertices
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
extension InlinerCache.Vertices
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
extension InlinerCache.Vertices
{
    subscript(_ scalar:Unidoc.Scalar) -> Volume.Vertex?
    {
        self.principal == scalar ? nil : self.secondary[scalar]
    }
}
