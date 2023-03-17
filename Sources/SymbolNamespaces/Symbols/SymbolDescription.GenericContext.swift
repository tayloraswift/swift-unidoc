import JSONDecoding

extension SymbolDescription
{
    struct GenericContext:Equatable, Sendable
    {
        /// Constraints directly specified by the relevant symbol.
        var constraints:[GenericConstraint<SymbolIdentifier>]
        /// Constraints inherited by the relevant symbol from its
        /// enclosing scope. These can be thought of as ‘extension’
        /// constraints, and can be used to group members by
        /// generic conditions.
        var conditions:[GenericConstraint<SymbolIdentifier>]
        /// All of the relevant symbol’s type parameters, including
        /// type parameters inherited from the enclosing scope, and
        /// type parameters shadowed by other type parameters.
        var parameters:[GenericParameter]

        private
        init(constraints:[GenericConstraint<SymbolIdentifier>] = [],
            conditions:[GenericConstraint<SymbolIdentifier>] = [],
            parameters:[GenericParameter] = [])
        {
            self.constraints = constraints
            self.conditions = conditions
            self.parameters = parameters
        }
    }
}
extension SymbolDescription.GenericContext
{
    init(conditions:[GenericConstraint<SymbolIdentifier>]?,
        generics:
        (
            constraints:[GenericConstraint<SymbolIdentifier>],
            parameters:[GenericParameter]
        )?)
    {
        switch (conditions, generics)
        {
        case (nil, nil):
            self.init()
        
        case (let conditions?, nil):
            self.init(conditions: conditions)
        
        case (nil, (let constraints, let parameters)?):
            self.init(constraints: constraints, parameters: parameters)
        
        case (let conditions?, (let constraints, let parameters)?):
            //  remove duplicated constraints
            let inherited:Set<GenericConstraint<SymbolIdentifier>> = .init(conditions)
            self.init(constraints: constraints.filter { !inherited.contains($0) },
                conditions: conditions,
                parameters: parameters)
        }
    }
}
