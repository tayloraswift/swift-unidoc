import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Unidoc

struct DynamicLinker
{
    private
    let context:DynamicContext
    private
    let conformances:SymbolGraph.Table<Conformances>

    private
    var extensions:Extensions
    private(set)
    var projection:Records
    private(set)
    var errors:[any DynamicLinkerError]

    private
    init(context:DynamicContext,
        conformances:SymbolGraph.Table<Conformances>,
        extensions:Extensions,
        errors:[any DynamicLinkerError])
    {
        self.context = context
        self.conformances = conformances

        self.extensions = extensions
        self.projection = .init()
        self.errors = errors
    }
}
extension DynamicLinker
{
    init(context:DynamicContext)
    {
        let groups:[DynamicResolutionGroup] = context.groups()

        var extensions:Extensions = .init(translator: context.current.translator)
        var errors:[any DynamicLinkerError] = []

        let conformances:SymbolGraph.Table<Conformances> = context.current.graph.nodes.map
        {
            $1.extensions.isEmpty ? [:] : extensions.add($1.extensions,
                //  we only need the conformances if the scalar has unqualified features
                indexingConformances: !($1.decl?.features.isEmpty ?? true),
                extending: $0,
                context: context,
                groups: groups,
                errors: &errors)
        }

        self.init(context: context,
            conformances: conformances,
            extensions: extensions,
            errors: errors)

        self.link(groups: groups)

        self.projection.extensions = self.extensions.records()
    }
}
extension DynamicLinker
{
    var current:SnapshotObject { self.context.current }
}
extension DynamicLinker
{
    private mutating
    func link(groups:[DynamicResolutionGroup])
    {
        for ((c, input), group):
            ((Int, SymbolGraph.Culture), DynamicResolutionGroup) in zip(zip(
                self.current.graph.cultures.indices,
                self.current.graph.cultures),
            groups)
        {
            let qualifier:ModuleIdentifier = self.current.graph.namespaces[c]
            let culture:Unidoc.Scalar = self.current.translator[culture: c]

            for namespace:SymbolGraph.Namespace in input.namespaces
            {
                self.link(namespace: namespace, of: culture, in: group)
            }
            if  let articles:ClosedRange<Int32> = input.articles
            {
                self.link(articles: articles, under: qualifier, in: group)
            }
            if  let article:SymbolGraph.Article<Never> = input.article
            {
                self.link(article: article, under: qualifier, for: culture, in: group)
            }
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(articles:ClosedRange<Int32>,
        under namespace:ModuleIdentifier,
        in group:DynamicResolutionGroup)
    {
        for (a, article):(Int32, SymbolGraph.Article<String>) in zip(
            self.current.graph.articles[articles].indices,
            self.current.graph.articles[articles])
        {
            var linked:Record.Master.Article = .init(id: self.current.translator[citizen: a])
            var resolver:DynamicResolver = .init(context: self.context,
                namespace: namespace,
                group: group)

            (linked.overview, linked.details) = resolver.link(article: article)

            self.projection.articles.append(linked)
            self.errors += resolver.errors
        }
    }

    private mutating
    func link(article:SymbolGraph.Article<Never>,
        under namespace:ModuleIdentifier,
        for culture:Unidoc.Scalar,
        in group:DynamicResolutionGroup)
    {
        var resolver:DynamicResolver = .init(context: self.context,
            namespace: namespace,
            group: group)

        var linked:Record.Master.Module = .init(id: culture)

        (linked.overview, linked.details) = resolver.link(article: article)

        self.projection.modules.append(linked)
        self.errors += resolver.errors
    }

    private mutating
    func link(namespace:SymbolGraph.Namespace,
        of culture:Unidoc.Scalar,
        in group:DynamicResolutionGroup)
    {
        let qualifier:ModuleIdentifier = self.current.graph.namespaces[namespace.index]

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
                    for conformance:ExtensionSignature in conformances[to: `protocol`]
                    {
                        self.extensions[conformance].features.append(f)
                    }
                }
            }

            let superforms:[Unidoc.Scalar] = scalar.superforms.compactMap
            {
                if  let s:Unidoc.Scalar = self.current.decls[$0]
                {
                    let implicit:ExtensionSignature = .init(conditions: [],
                        culture: culture,
                        extends: s)

                    self.extensions[implicit].subforms.append(d)
                    return s
                }
                else
                {
                    return nil
                }
            }

            var linked:Record.Master.Decl = .init(id: d,
                signature: scalar.signature.map { self.current.decls[$0] },
                superforms: superforms,
                culture: culture,
                scope: scope.map { self.context.expand($0) })

            if  let article:SymbolGraph.Article<Never> = scalar.article
            {
                var resolver:DynamicResolver = .init(context: self.context,
                    namespace: qualifier,
                    group: group,
                    scope: scalar.phylum.scope(trimming: scalar.path))

                (linked.overview, linked.details) = resolver.link(article: article)

                self.errors += resolver.errors
            }

            self.projection.decls.append(linked)
        }
    }
}
