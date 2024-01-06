import Signatures
import Unidoc

extension Unidoc
{
    @frozen public
    struct ConformerGroup:Identifiable, Equatable, Sendable
    {
        public
        let id:Group
        public
        let culture:Scalar
        public
        let scope:Scalar

        public
        var types:[ConformingType]

        @inlinable public
        init(id:Group, culture:Scalar, scope:Scalar, types:[ConformingType] = [])
        {
            self.id = id
            self.culture = culture
            self.scope = scope
            self.types = types
        }
    }
}
