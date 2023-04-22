import Generics
import JSONDecoding
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
        let conditions:[GenericConstraint<Symbol.Scalar>]

        @inlinable public
        init(conditions:[GenericConstraint<Symbol.Scalar>] = [])
        {
            self.conditions = conditions
        }
    }
}
extension SymbolDescription.ExtensionContext:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case conditions = "constraints"
    }
    
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(conditions: try json[.conditions]?.decode() ?? [])
    }
}
