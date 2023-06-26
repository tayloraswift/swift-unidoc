import Declarations
import SymbolGraphs

@frozen public
struct ScalarProjection:Equatable, Sendable
{
    public
    let id:Scalar96

    public
    let culture:Scalar96
    public
    let scope:[Scalar96]?

    public
    let declaration:Declaration<Scalar96?>

    public
    var superforms:[Scalar96]

    init(id:Scalar96,
        culture:Scalar96,
        scope:[Scalar96]?,
        declaration:Declaration<Scalar96?>)
    {
        self.id = id

        self.culture = culture
        self.scope = scope
        self.declaration = declaration

        self.superforms = []
    }
}
