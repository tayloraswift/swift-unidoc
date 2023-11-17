import Unidoc
import UnidocRecords

extension IdentifiablePageContext
{
    struct Vertices
    {
        let principal:ID
        private(set)
        var secondary:[Unidoc.Scalar: Volume.Vertex]

        init(
            principal:ID,
            secondary:[Unidoc.Scalar: Volume.Vertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension IdentifiablePageContext.Vertices where ID:VersionedPageIdentifier
{
    mutating
    func add(_ masters:[Volume.Vertex])
    {
        for master:Volume.Vertex in masters where self.principal != master.id
        {
            self.secondary[master.id] = master
        }
    }

    subscript(_ scalar:Unidoc.Scalar) -> Volume.Vertex?
    {
        self.principal != scalar ? self.secondary[scalar] : nil
    }
}
