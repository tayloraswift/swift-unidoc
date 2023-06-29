import Signatures
import Unidoc

extension Record.Master
{
    @frozen public
    struct Decl:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let signature:Signature<Unidoc.Scalar?>

        public
        let superforms:[Unidoc.Scalar]
        public
        let culture:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]?

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        init(id:Unidoc.Scalar,
            signature:Signature<Unidoc.Scalar?>,
            superforms:[Unidoc.Scalar],
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar]?,
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id

            self.signature = signature
            self.superforms = superforms
            self.culture = culture
            self.scope = scope

            self.overview = overview
            self.details = details
        }
    }
}
