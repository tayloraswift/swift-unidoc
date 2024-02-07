import Unidoc
import UnidocRecords

extension Unidoc.Linker
{
    @available(*, deprecated)
    typealias Extension = Unidoc.Extension
}
extension Unidoc
{
    @available(*, deprecated)
    typealias ExtensionBody = Unidoc.Extension

    struct Extension:Identifiable
    {
        let id:LinkerIndex<Self>

        var conformances:[Unidoc.Scalar]
        var features:[Unidoc.Scalar]
        var nested:[Unidoc.Scalar]
        var subforms:[Unidoc.Scalar]

        var overview:Unidoc.Passage?
        var details:Unidoc.Passage?

        init(id:LinkerIndex<Self>)
        {
            self.id = id

            self.conformances = []
            self.features = []
            self.nested = []
            self.subforms = []

            self.overview = nil
            self.details = nil
        }
    }
}
extension Unidoc.Extension:Unidoc.LinkerIndexable
{
    typealias Signature = Unidoc.ExtensionSignature

    static
    var type:Unidoc.GroupType { .extension }

    var isEmpty:Bool
    {
        self.conformances.isEmpty &&
        self.features.isEmpty &&
        self.nested.isEmpty &&
        self.subforms.isEmpty &&
        self.overview == nil &&
        self.details == nil
    }

    __consuming
    func assemble(signature:Unidoc.ExtensionSignature,
        with linker:borrowing Unidoc.Linker) -> Unidoc.ExtensionGroup
    {
        .init(id: self.id.in(linker.current.id),
            constraints: signature.conditions.constraints,
            culture: linker.current.id + signature.culture,
            scope: signature.extendee,
            conformances: linker.sort(self.conformances, by: Unidoc.SemanticPriority.self),
            features: linker.sort(self.features, by: Unidoc.SemanticPriority.self),
            nested: linker.sort(self.nested, by: Unidoc.SemanticPriority.self),
            subforms: linker.sort(self.subforms, by: Unidoc.SemanticPriority.self),
            overview: self.overview,
            details: self.details)
    }
}
