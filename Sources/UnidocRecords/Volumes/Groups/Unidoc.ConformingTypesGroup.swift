import Signatures
import Unidoc

extension Unidoc
{
    @frozen public
    struct ConformingTypesGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Group.ID
        public
        let constraints:[GenericConstraint<Unidoc.Scalar?>]
        public
        let culture:Unidoc.Scalar
        public
        let scope:Unidoc.Scalar

        public
        var types:[Unidoc.Scalar]

        @inlinable public
        init(id:Unidoc.Group.ID,
            constraints:[GenericConstraint<Unidoc.Scalar?>],
            culture:Unidoc.Scalar,
            scope:Unidoc.Scalar,
            types:[Unidoc.Scalar] = [])
        {
            self.id = id
            self.constraints = constraints
            self.culture = culture
            self.scope = scope
            self.types = types
        }
    }
}
