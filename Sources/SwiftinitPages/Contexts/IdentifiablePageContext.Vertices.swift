import Unidoc
import UnidocRecords

extension IdentifiablePageContext
{
    struct Vertices
    {
        let principal:ID
        private(set)
        var secondary:[Unidoc.Scalar: Unidoc.Vertex]

        init(
            principal:ID,
            secondary:[Unidoc.Scalar: Unidoc.Vertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension IdentifiablePageContext.Vertices where ID:VersionedPageIdentifier
{
    mutating
    func add(_ masters:[Unidoc.Vertex])
    {
        for master:Unidoc.Vertex in masters where self.principal != master.id
        {
            self.secondary[master.id] = master
        }
    }

    subscript(_ scalar:Unidoc.Scalar) -> Unidoc.Vertex?
    {
        self.principal != scalar ? self.secondary[scalar] : nil
    }
}
