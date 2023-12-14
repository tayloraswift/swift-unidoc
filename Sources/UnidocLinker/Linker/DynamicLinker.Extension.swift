import Unidoc
import UnidocRecords

extension DynamicLinker
{
    struct Extension:Identifiable, Equatable, Sendable
    {
        let id:Unidoc.Scalar

        var conformances:[Unidoc.Scalar]
        var features:[Unidoc.Scalar]
        var nested:[Unidoc.Scalar]
        var subforms:[Unidoc.Scalar]

        var overview:Unidoc.Passage?
        var details:Unidoc.Passage?

        init(id:Unidoc.Scalar,
            conformances:[Unidoc.Scalar] = [],
            features:[Unidoc.Scalar] = [],
            nested:[Unidoc.Scalar] = [],
            subforms:[Unidoc.Scalar] = [],
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil)
        {
            self.id = id

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.subforms = subforms

            self.overview = overview
            self.details = details
        }
    }
}
extension DynamicLinker.Extension
{
    var isEmpty:Bool
    {
        self.conformances.isEmpty &&
        self.features.isEmpty &&
        self.nested.isEmpty &&
        self.subforms.isEmpty &&
        self.overview == nil &&
        self.details == nil
    }
}
