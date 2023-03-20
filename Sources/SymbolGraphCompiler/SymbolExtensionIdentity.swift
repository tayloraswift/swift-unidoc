struct SymbolExtensionIdentity<TypeReference>:Hashable where TypeReference:Hashable
{
    let type:TypeReference
    let conditions:[GenericConstraint<TypeReference>]

    init(_ type:TypeReference, where conditions:[GenericConstraint<TypeReference>])
    {
        self.type = type
        self.conditions = conditions
    }
}
