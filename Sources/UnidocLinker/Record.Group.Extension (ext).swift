import Signatures
import UnidocRecords
import Unidoc

extension Record.Group.Extension
{
    init(signature:DynamicLinker.ExtensionSignature,
        extension:DynamicLinker.Extension,
        context:DynamicContext)
    {
        var scalars:Set<Unidoc.Scalar> = [signature.culture]

        scalars.formUnion(`extension`.conformances)
        scalars.formUnion(`extension`.features)
        scalars.formUnion(`extension`.nested)
        scalars.formUnion(`extension`.subforms)

        for constraint:GenericConstraint<Unidoc.Scalar?> in signature.conditions
        {
            if  case let scalar?? = constraint.whom.nominal
            {
                scalars.update(with: scalar)
            }
        }

        let prefetch:[Unidoc.Scalar] = []
        //  TODO: compute tertiary scalars

        self.init(id: `extension`.id,
            conditions: signature.conditions,
            culture: signature.culture,
            scope: signature.extends,
            conformances: `extension`.conformances,
            features: `extension`.features,
            nested: `extension`.nested,
            subforms: `extension`.subforms,
            prefetch: prefetch,
            overview: `extension`.overview,
            details: `extension`.details)
    }
}
