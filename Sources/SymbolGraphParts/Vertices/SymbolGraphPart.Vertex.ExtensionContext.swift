import JSONDecoding
import Signatures
import Symbols

extension SymbolGraphPart.Vertex
{
    @frozen public
    struct ExtensionContext:Equatable, Hashable, Sendable
    {
        /// Constraints inherited by the relevant symbol from its
        /// enclosing scope. These can be thought of as ‘extension’
        /// constraints, and can be used to group members by
        /// generic constraints.
        public
        let conditions:[GenericConstraint<Symbol.Decl>]

        @inlinable public
        init(conditions:[GenericConstraint<Symbol.Decl>] = [])
        {
            self.conditions = conditions
        }
    }
}
extension SymbolGraphPart.Vertex.ExtensionContext:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case constraints

        @available(*, unavailable, message: "Not useful")
        case extendedModule
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(conditions: try json[.constraints]?.decode() ?? [])
    }
}
