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

        private
        init(id:LinkerIndex<Self>,
            conformances:[Unidoc.Scalar],
            features:[Unidoc.Scalar],
            nested:[Unidoc.Scalar],
            subforms:[Unidoc.Scalar],
            overview:Unidoc.Passage? ,
            details:Unidoc.Passage? )
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
extension Unidoc.Extension:Unidoc.LinkerIndexable
{
    typealias Signature = Unidoc.ExtensionSignature

    static
    var type:Unidoc.GroupType { .extension }

    init(id:Unidoc.LinkerIndex<Self>)
    {
        self.init(id: id,
            conformances: [],
            features: [],
            nested: [],
            subforms: [],
            overview: nil,
            details: nil)
    }

    var isEmpty:Bool
    {
        self.conformances.isEmpty &&
        self.features.isEmpty &&
        self.nested.isEmpty &&
        self.subforms.isEmpty &&
        self.overview == nil &&
        self.details == nil
    }

    func assemble(signature:Unidoc.ExtensionSignature,
        with linker:borrowing Unidoc.Linker) -> Unidoc.ExtensionGroup
    {
        let prefetch:[Unidoc.Scalar] = []
        //  TODO: compute tertiary scalars

        return .init(id: self.id.in(linker.current.id),
            constraints: signature.conditions.constraints,
            culture: linker.current.id + signature.culture,
            scope: signature.extendee,
            conformances: linker.sort(lexically: self.conformances),
            features: linker.sort(lexically: self.features),
            nested: linker.sort(lexically: self.nested),
            subforms: linker.sort(lexically: self.subforms),
            prefetch: prefetch,
            overview: self.overview,
            details: self.details)
    }
}
