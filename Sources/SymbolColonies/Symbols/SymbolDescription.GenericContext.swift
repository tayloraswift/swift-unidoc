import JSONDecoding

extension SymbolDescription
{
    @frozen public
    struct GenericContext:Equatable, Sendable
    {
        public
        var constraints:[GenericConstraint<ScalarSymbolResolution>]
        /// All of the relevant symbol’s type parameters, including
        /// type parameters inherited from the enclosing scope, and
        /// type parameters shadowed by other type parameters.
        public
        var parameters:[GenericParameter]

        @inlinable public
        init(constraints:[GenericConstraint<ScalarSymbolResolution>] = [],
            parameters:[GenericParameter] = [])
        {
            self.constraints = constraints
            self.parameters = parameters
        }
    }
}
extension SymbolDescription.GenericContext:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case parameters
        case constraints
    }
    
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            constraints: try json[.constraints]?.decode() ?? [],
            parameters: try json[.parameters]?.decode() ?? [])
    }
}
