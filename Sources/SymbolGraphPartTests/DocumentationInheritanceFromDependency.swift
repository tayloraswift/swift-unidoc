import SymbolGraphParts
import Symbols
import Testing

@Suite
struct DocumentationInheritanceFromDependency
{
    private
    let symbols:SymbolGraphPart

    init() throws
    {
        self.symbols = try .load(
            part: "TestModules/SymbolGraphs/DocumentationInheritanceFromSwift.symbols.json")
    }

    @Test(arguments: [
            (
                ["Documented", "id"],
                "DocumentationInheritanceFromSwift",
                "A documented id property."
            ),
            (
                ["Undocumented", "id"],
                nil,
                nil
            ),
        ] as [([String], Symbol.Module?, String?)])
    func Comments(_ symbol:[String], _ culture:Symbol.Module?, _ comment:String?) throws
    {
        let vertex:SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.doccomment?.culture == culture)
        #expect(vertex?.doccomment?.text == comment)
    }

    @Test
    func Origins() throws
    {
        let relationships:Set<Symbol.AnyRelationship> = self.symbols.relationships.reduce(
            into: [])
        {
            if  case .member(let membership) = $1,
                case _? = membership.origin
            {
                $0.insert($1)
            }
        }
        /// Concrete type members always get an origin edge pointing back
        /// to whatever requirement they fulfill, regardless of whether:
        ///
        /// -   they already have documentation of their own, or
        /// -   they had no documentation, and inherited no documentation.
        ///
        /// In both cases, they will get an edge to their immediate origin.
        /// If concrete type members do inherit documentation, their origin
        /// edges point to the symbols they inherited documenation from,
        /// even if there were undocumented symbols in between. (The edges
        /// “skip” the undocumented symbols.)
        ///
        /// Default implementations only get an origin edge if they actually
        /// had no documentation of their own, and successfully inherited some.
        #expect(relationships == [
                .member(.init("""
                    s33DocumentationInheritanceFromSwift12UndocumentedV2ids5NeverOSgvp
                    """,
                    in: .scalar("s33DocumentationInheritanceFromSwift12UndocumentedV"),
                    origin: "ss12IdentifiableP2id2IDQzvp")),

                .member(.init("""
                    s33DocumentationInheritanceFromSwift10DocumentedV2ids5NeverOSgvp
                    """,
                    in: .scalar("s33DocumentationInheritanceFromSwift10DocumentedV"),
                    origin: "ss12IdentifiableP2id2IDQzvp")),
            ])
    }
}
