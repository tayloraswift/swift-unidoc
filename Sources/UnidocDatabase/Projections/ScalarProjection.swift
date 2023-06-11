import Declarations
import SymbolGraphs

@frozen public
struct ScalarProjection:Equatable, Sendable
{
    public
    let id:GlobalAddress

    public
    let culture:GlobalAddress
    public
    let scope:[GlobalAddress]?

    public
    let declaration:Declaration<GlobalAddress?>

    public
    var superforms:[GlobalAddress]

    init(id:GlobalAddress,
        culture:GlobalAddress,
        scope:[GlobalAddress]?,
        declaration:Declaration<GlobalAddress?>)
    {
        self.id = id

        self.culture = culture
        self.scope = scope
        self.declaration = declaration

        self.superforms = []
    }
}
