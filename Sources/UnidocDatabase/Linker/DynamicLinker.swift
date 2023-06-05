import SymbolGraphs
import Symbols

struct DynamicLinker
{
    private
    let context:GlobalContext

    private
    var extensions:Extensions
    private
    let conformances:[Conformances]

    private
    init(context:GlobalContext, extensions:Extensions, conformances:[Conformances])
    {
        self.context = context

        self.extensions = extensions
        self.conformances = conformances
    }
}
extension DynamicLinker
{
    init(context:GlobalContext)
    {
        var extensions:Extensions = .init()
        let conformances:[Conformances] = extensions.conformances(in: context.current)
        self.init(context: context, extensions: extensions, conformances: conformances)
    }
}
extension DynamicLinker
{
    var current:LocalContext { self.context.current }
}
extension DynamicLinker
{
    mutating
    func project() -> [ScalarProjection]
    {
        var scalars:[ScalarProjection] = []

        for (culture, module):(Int, Documentation.Module)
            in self.current.docs.modules.enumerated()
        {
            guard let range:ClosedRange<ScalarAddress> = module.range
            else
            {
                continue
            }

            let cultureID:GlobalAddress = self.current.translator[culture: culture]
            for citizen:ScalarAddress in range
            {
                let node:SymbolGraph.Node = self.current.docs.graph[allocated: citizen]

                guard   let scalar:SymbolGraph.Scalar = node.scalar,
                        let citizenID:GlobalAddress = citizen * self.current.projector
                else
                {
                    continue
                }

                for feature:ScalarAddress in scalar.features
                {
                    if  let featureID:GlobalAddress = feature * self.current.projector,
                        let `protocol`:GlobalAddress = self.current.scope(of: feature)
                    {
                        //  now that we know the address of the feature’s original protocol,
                        //  we can look up the constraints for the conformance(s) that
                        //  conceived it.
                        for conformance:GlobalSignature in self.conformances[citizen.offset][
                            to: `protocol`]
                        {
                            self.extensions[conformance].features.append(featureID)
                        }
                    }
                }
                for superform:ScalarAddress in scalar.superforms
                {
                    if  let superformID:GlobalAddress = superform * self.current.projector
                    {
                        let implicit:GlobalSignature = .init(conditions: [],
                            culture: cultureID,
                            scope: superformID)

                        self.extensions[implicit].subforms.append(citizenID)
                    }
                }

                let scope:[GlobalAddress]? = self.current.scope(of: citizen).map
                {
                    self.context.expand($0)
                }

                scalars.append(.init(id: citizenID,
                    culture: cultureID,
                    scope: scope,
                    declaration: scalar.declaration.map { $0 * self.current.projector }))
            }
        }

        return scalars
    }
}
