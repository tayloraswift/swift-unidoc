import Declarations
import Unidoc

@frozen public
struct ScalarProjection:Equatable, Sendable
{
    public
    let id:Unidoc.Scalar

    public
    let culture:Unidoc.Scalar
    public
    let scope:[Unidoc.Scalar]?

    public
    let declaration:Declaration<Unidoc.Scalar?>

    public
    var superforms:[Unidoc.Scalar]

    init(id:Unidoc.Scalar,
        culture:Unidoc.Scalar,
        scope:[Unidoc.Scalar]?,
        declaration:Declaration<Unidoc.Scalar?>)
    {
        self.id = id

        self.culture = culture
        self.scope = scope
        self.declaration = declaration

        self.superforms = []
    }
}
