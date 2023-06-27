import Signatures
import Unidoc

extension Projection
{
    @frozen public
    struct Extension:Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let conditions:[GenericConstraint<Unidoc.Scalar?>]
        public
        let culture:Unidoc.Scalar
        public
        let scope:Unidoc.Scalar

        public
        let conformances:[Unidoc.Scalar]
        public
        let features:[Unidoc.Scalar]
        public
        let nested:[Unidoc.Scalar]
        public
        let subforms:[Unidoc.Scalar]

        init(id:Unidoc.Scalar,
            conditions:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [])
        {
            self.id = id

            self.conditions = conditions
            self.culture = culture
            self.scope = scope

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.subforms = subforms
        }
    }
}
extension Projection.Extension
{
    init(signature:DynamicLinker.ExtensionSignature,
        extension:DynamicLinker.Extension)
    {
        self.init(id: `extension`.id,
            conditions: signature.conditions,
            culture: signature.culture,
            scope: signature.extends,
            conformances: `extension`.conformances,
            features: `extension`.features,
            nested: `extension`.nested,
            subforms: `extension`.subforms)
    }
}
