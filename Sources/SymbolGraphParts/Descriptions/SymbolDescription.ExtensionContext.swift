import JSONDecoding
import Signatures
import Symbols

extension SymbolDescription
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
extension SymbolDescription.ExtensionContext:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case conditions = "constraints"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(conditions: try json[.conditions]?.decode() ?? [])
    }
}
