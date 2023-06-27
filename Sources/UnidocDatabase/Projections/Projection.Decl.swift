import Signatures
import Unidoc

extension Projection
{
    @frozen public
    struct Decl:Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let culture:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]?

        public
        let signature:Signature<Unidoc.Scalar?>

        public
        var superforms:[Unidoc.Scalar]

        init(id:Unidoc.Scalar,
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar]?,
            signature:Signature<Unidoc.Scalar?>)
        {
            self.id = id

            self.culture = culture
            self.scope = scope
            self.signature = signature

            self.superforms = []
        }
    }
}
