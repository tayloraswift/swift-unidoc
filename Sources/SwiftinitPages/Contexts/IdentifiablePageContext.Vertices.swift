import Unidoc
import UnidocRecords

extension IdentifiablePageContext
{
    struct Vertices
    {
        let principal:ID
        private(set)
        var secondary:[Unidoc.Scalar: Unidoc.AnyVertex]

        init(
            principal:ID,
            secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension IdentifiablePageContext.Vertices where ID:Swiftinit.VertexPageIdentifier
{
    mutating
    func add(_ masters:[Unidoc.AnyVertex])
    {
        for master:Unidoc.AnyVertex in masters where self.principal != master.id
        {
            self.secondary[master.id] = master
        }
    }

    subscript(_ scalar:Unidoc.Scalar) -> Unidoc.AnyVertex?
    {
        self.principal != scalar ? self.secondary[scalar] : nil
    }
}
