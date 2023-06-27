import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Unidoc

struct DynamicLinker
{
    private
    let conformances:SymbolGraph.Table<Conformances>
    private
    let context:DynamicContext

    private
    var extensions:Extensions
    private
    var decls:[Projection.Decl]

    private(set)
    var diagnoses:[any DynamicDiagnosis]

    private
    init(conformances:SymbolGraph.Table<Conformances>,
        context:DynamicContext,
        extensions:Extensions)
    {
        self.conformances = conformances
        self.context = context

        self.extensions = extensions
        self.diagnoses = []
        self.decls = []
    }
}
extension DynamicLinker
{
    var current:SnapshotObject { self.context.current }

    func projection() -> Projection
    {
        .init(extensions: self.extensions.sorted(), decls: self.decls)
    }
}
extension DynamicLinker
{
    init(context:DynamicContext)
    {
        var extensions:Extensions = .init(translator: context.current.translator)
        let conformances:SymbolGraph.Table<Conformances> = extensions.add(
            from: context.current)

        self.init(conformances: conformances, context: context, extensions: extensions)

        self.project()
    }
}
extension DynamicLinker
{
    private mutating
    func project()
    {
        for ((c, culture), group):
            ((Int, SymbolGraph.Culture), DynamicResolutionGroup) in zip(zip(
                self.current.graph.cultures.indices,
                self.current.graph.cultures),
            self.context.groups())
        {
            let qualifier:ModuleIdentifier = self.current.graph.namespaces[c]
            let c:Unidoc.Scalar = self.current.translator[culture: c]

            for namespace:SymbolGraph.Namespace in culture.namespaces
            {
                let qualifier:ModuleIdentifier =
                    self.current.graph.namespaces[namespace.index]

                for (d, (node, conformances)):
                    (Int32, (SymbolGraph.Node, Conformances)) in zip(namespace.range, zip(
                    self.current.graph.nodes[namespace.range],
                    self.conformances[namespace.range]))
                {
                    let scope:Unidoc.Scalar? = self.current.scope(of: d)

                    //  Ceremonial unwraps, should always succeed since we are only iterating
                    //  over module ranges.
                    guard   let scalar:SymbolGraph.Decl = node.decl,
                            let d:Unidoc.Scalar = self.current.decls[d]
                    else
                    {
                        continue
                    }

                    for f:Int32 in scalar.features
                    {
                        if  let `protocol`:Unidoc.Scalar = self.current.scope(of: f),
                            let f:Unidoc.Scalar = self.current.decls[f]
                        {
                            //  now that we know the address of the feature’s original
                            //  protocol, we can look up the constraints for the
                            //  conformance(s) that conceived it.
                            for conformance:ExtensionSignature in
                                conformances[to: `protocol`]
                            {
                                self.extensions[conformance].features.append(f)
                            }
                        }
                    }
                    for s:Int32 in scalar.superforms
                    {
                        if  let s:Unidoc.Scalar = self.current.decls[s]
                        {
                            let implicit:ExtensionSignature = .init(conditions: [],
                                culture: c,
                                extends: s)

                            self.extensions[implicit].subforms.append(d)
                        }
                    }

                    if  let article:SymbolGraph.Article<Never> = scalar.article
                    {
                        var resolver:DynamicResolver = .init(context: self.context,
                            namespace: qualifier,
                            group: group,
                            scope: scalar.phylum.scope(trimming: scalar.path))

                        resolver.link(article: article)

                        self.diagnoses += resolver.diagnoses
                    }

                    self.decls.append(.init(id: d,
                        culture: c,
                        scope: scope.map { self.context.expand($0) },
                        signature: scalar.signature.map { self.current.decls[$0] }))
                }
            }
            if  let articles:ClosedRange<Int32> = culture.articles
            {
                for article:SymbolGraph.Article<String> in self.current.graph.articles[articles]
                {
                    var resolver:DynamicResolver = .init(context: self.context,
                        namespace: qualifier,
                        group: group)

                    resolver.link(article: article)

                    self.diagnoses += resolver.diagnoses
                }
            }
            if  let article:SymbolGraph.Article<Never> = culture.article
            {
                var resolver:DynamicResolver = .init(context: self.context,
                    namespace: qualifier,
                    group: group)

                resolver.link(article: article)

                self.diagnoses += resolver.diagnoses
            }
        }
    }
}
