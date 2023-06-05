import SymbolGraphs
import Generics

struct GlobalContext
{
    var upstream:[Int32: DocumentationObject.Context]
    let current:DocumentationObject.Context

    init(upstream:[Int32: DocumentationObject.Context] = [:],
        current:DocumentationObject.Context)
    {
        self.upstream = upstream
        self.current = current
    }
}
extension GlobalContext
{
    subscript(package:Int32) -> DocumentationObject.Context?
    {
        self.current.id == package ? self.current : self.upstream[package]
    }

    private
    func expand(_ address:GlobalAddress) -> [GlobalAddress]
    {
        var current:GlobalAddress = address
        var path:[GlobalAddress] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<GlobalAddress> = [current]

        while   let next:GlobalAddress = self[current.package]?.scope(of: current),
                case nil = seen.update(with: next)
        {
            path.append(next)
            current = next
        }

        return path.reversed()
    }
}

struct ExtensionConformance
{
    let signature:ExtensionSignature
    let id:LocalSignature

    init(signature:ExtensionSignature, id:LocalSignature)
    {
        self.signature = signature
        self.id = id
    }
}
struct ExtensionSignature
{
    let conditions:[GenericConstraint<GlobalAddress?>]
    let culture:GlobalAddress

    init(conditions:[GenericConstraint<GlobalAddress?>], culture:GlobalAddress)
    {
        self.conditions = conditions
        self.culture = culture
    }
}

extension GlobalContext
{
    func project() -> [ScalarProjection]
    {
        var extensions:[LocalSignature: ExtensionProjection] = [:]
        let conformances:[[GlobalAddress: [ExtensionConformance]]] =
            self.current.docs.graph.allocated.map
        {
            let node:SymbolGraph.Node = self.current.docs.graph[allocated: $0]
            if  node.extensions.isEmpty
            {
                return [:]
            }
            guard let scope:GlobalAddress = $0 * self.current.projector
            else
            {
                return [:]
            }

            var conformances:[GlobalAddress: [ExtensionConformance]] = [:]
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                let signature:LocalSignature = .init(extension: `extension`, of: $0)
                let projected:ExtensionProjection = self.current.project(
                    extension: `extension`,
                    of: scope)

                //  we only need the conformances if the scalar has unqualified features
                if case false? = node.scalar?.features.isEmpty
                {
                    let conformance:ExtensionConformance = .init(signature: .init(
                            conditions: projected.conditions,
                            culture: projected.culture),
                        id: signature)

                    for `protocol`:GlobalAddress in projected.conformances
                    {
                        conformances[`protocol`, default: []].append(conformance)
                    }
                }

                extensions[signature] = projected
            }

            return conformances
        }

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
                        let `protocol`:GlobalAddress = self.current.scope(of: feature),
                        case .protocol? = self[`protocol`.package]?[`protocol`]?.scalar?.phylum
                    {
                        //  now that we know the address of the feature’s original protocol,
                        //  we can look up the constraints for the conformance(s) that
                        //  conceived it.
                        for conformance:ExtensionConformance in
                            conformances[citizen.offset][`protocol`, default: []]
                        {
                            var implicit:ExtensionProjection
                            {
                                .init(conditions: conformance.signature.conditions,
                                    culture: conformance.signature.culture,
                                    scope: citizenID)
                            }

                            extensions[conformance.id, default: implicit].features
                                .append(featureID)
                        }
                    }
                }
                for superform:ScalarAddress in scalar.superforms
                {
                    if  let superformID:GlobalAddress = superform * self.current.projector
                    {
                        var implicit:ExtensionProjection
                        {
                            .init(conditions: [], culture: cultureID, scope: superformID)
                        }
                        let key:LocalSignature = .init(conditions: [],
                            culture: culture,
                            scope: superform)

                        extensions[key, default: implicit].subforms.append(citizenID)
                    }
                }

                let scope:[GlobalAddress]? = self.current.scope(of: citizen).map(self.expand)

                scalars.append(.init(id: citizenID,
                    culture: cultureID,
                    scope: scope,
                    declaration: scalar.declaration.map { $0 * self.current.projector }))
            }
        }

        return scalars
    }
}
