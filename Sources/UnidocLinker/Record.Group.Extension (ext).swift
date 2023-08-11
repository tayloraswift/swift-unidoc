import Signatures
import UnidocRecords
import Unidoc

extension Record.Group.Extension
{
    init(signature:DynamicLinker.ExtensionSignature,
        extension:DynamicLinker.Extension,
        context:DynamicContext)
    {
        let prefetch:[Unidoc.Scalar] = []
        //  TODO: compute tertiary scalars

        self.init(id: `extension`.id,
            conditions: signature.conditions,
            culture: signature.culture,
            scope: signature.extends,
            requirements: context.sort(lexically: `extension`.requirements),
            conformances: context.sort(lexically: `extension`.conformances),
            features: context.sort(lexically: `extension`.features),
            nested: context.sort(lexically: `extension`.nested),
            subforms: context.sort(lexically: `extension`.subforms),
            prefetch: prefetch,
            overview: `extension`.overview,
            details: `extension`.details)
    }
}
