import SymbolGraphs
import Unidoc

extension DynamicLinker
{
    struct Extensions
    {
        private
        var projections:[ExtensionSignature: Extension]
        private
        let translator:Snapshot.Translator

        init(translator:Snapshot.Translator,
            projections:[ExtensionSignature: Extension] = [:])
        {
            self.projections = projections
            self.translator = translator
        }
    }
}
extension DynamicLinker.Extensions
{
    var count:Int
    {
        self.projections.count
    }

    func sorted() -> [Projection.Extension]
    {
        self.projections.sorted { $0.value.id < $1.value.id }
            .map
        {
            .init(signature: $0.key, extension: $0.value)
        }
    }
}
extension DynamicLinker.Extensions
{
    subscript(signature:DynamicLinker.ExtensionSignature) -> DynamicLinker.Extension
    {
        _read
        {
            let next:Unidoc.Scalar = self.translator[citizen: .extension | self.count]
            yield  self.projections[signature, default: .init(id: next)]
        }
        _modify
        {
            let next:Unidoc.Scalar = self.translator[citizen: .extension | self.count]
            yield &self.projections[signature, default: .init(id: next)]
        }
    }
}
extension DynamicLinker.Extensions
{
    mutating
    func add(from current:SnapshotObject) -> SymbolGraph.Table<DynamicLinker.Conformances>
    {
        current.graph.nodes.map
        {
            if  $1.extensions.isEmpty
            {
                return [:]
            }
            guard let scope:Unidoc.Scalar = current.decls[$0]
            else
            {
                return [:]
            }

            var conformances:DynamicLinker.Conformances = [:]
            for `extension`:SymbolGraph.Extension in $1.extensions
            {
                let signature:DynamicLinker.ExtensionSignature = .init(
                    conditions: `extension`.conditions.map
                    {
                        $0.map { current.decls[$0] }
                    },
                    culture: current.translator[culture: `extension`.culture],
                    extends: scope)

                let protocols:[Unidoc.Scalar] =
                    `extension`.conformances.compactMap { current.decls[$0] }

                //  It’s possible for two locally-disjoint extensions to coalesce
                //  into a single global extension due to constraint dropping...
                {
                    $0.conformances += protocols
                    $0.features += `extension`.features.compactMap { current.decls[$0] }
                    $0.nested += `extension`.nested.compactMap { current.decls[$0] }

                } (&self[signature])
                //  we only need the conformances if the scalar has unqualified features
                if case false? = $1.decl?.features.isEmpty
                {
                    for `protocol`:Unidoc.Scalar in protocols
                    {
                        conformances[to: `protocol`].append(signature)
                    }
                }
            }
            return conformances
        }
    }
}
