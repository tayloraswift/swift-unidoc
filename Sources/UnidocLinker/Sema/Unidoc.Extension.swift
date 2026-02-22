import Unidoc
import UnidocRecords

extension Unidoc {
    struct Extension: Identifiable {
        let id: LinkerIndex<Self>

        var conformances: [Unidoc.Scalar]
        var features: [Unidoc.Scalar]
        var nested: [Unidoc.Scalar]
        var subforms: [Unidoc.Scalar]

        var overview: Unidoc.Passage?
        var details: Unidoc.Passage?

        init(id: LinkerIndex<Self>) {
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
extension Unidoc.Extension: Unidoc.LinkerIndexable {
    typealias Signature = Unidoc.ExtensionSignature

    static var type: Unidoc.GroupType { .extension }

    var isEmpty: Bool {
        self.conformances.isEmpty &&
        self.features.isEmpty &&
        self.nested.isEmpty &&
        self.subforms.isEmpty &&
        self.overview == nil &&
        self.details == nil
    }

    consuming func assemble(
        signature: Unidoc.ExtensionSignature,
        with context: Unidoc.LinkerContext
    ) -> Unidoc.ExtensionGroup {
        .init(
            id: self.id.in(context.current.id),
            constraints: signature.conditions.constraints,
            culture: context.current.id + signature.culture,
            scope: signature.extendee,
            conformances: context.sort(
                self.conformances,
                by: Unidoc.SemanticPriority.self
            ),
            features: context.sort(
                self.features,
                by: Unidoc.SemanticPriority.self
            ),
            nested: context.sort(
                self.nested,
                by: Unidoc.SemanticPriority.self
            ),
            subforms: context.sort(
                self.subforms,
                by: Unidoc.SemanticPriority.self
            ),
            overview: self.overview,
            details: self.details
        )
    }
}
