import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

public
struct DynamicLinker
{
    private
    let context:DynamicContext
    private
    let conformances:SymbolGraph.Table<Conformances>

    private
    var extensions:Extensions
    public private(set)
    var projection:Records
    public private(set)
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
        self.projection = .init(zone: .init(context.current.snapshot.zone,
            package: context.current.snapshot.metadata.package,
            version: context.current.snapshot.metadata.version))
        self.errors = errors
    }
}
extension DynamicLinker
{
    public
    init(context:DynamicContext)
    {
        let groups:[DynamicResolutionGroup] = context.groups()

        var extensions:Extensions = .init(zone: context.current.zone)
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
            let namespace:ModuleIdentifier = self.current.graph.namespaces[c]
            let culture:Unidoc.Scalar = self.current.zone + c * .module

            for namespace:SymbolGraph.Namespace in input.namespaces
            {
                self.link(decls: namespace.range,
                    under: self.current.graph.namespaces[namespace.index],
                    of: culture,
                    in: group)
            }
            if  let articles:ClosedRange<Int32> = input.articles
            {
                self.link(articles: articles, under: namespace, in: group)
            }

            var record:Record.Master.Culture = .init(id: culture,
                module: input.module,
                stem: namespace)

            if  let article:SymbolGraph.Article<Never> = input.article
            {
                var resolver:DynamicResolver = .init(context: self.context,
                    namespace: namespace,
                    group: group)

                (record.overview, record.details) = resolver.link(article: article)

                self.errors += resolver.errors
            }

            self.projection.cultures.append(record)
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(articles range:ClosedRange<Int32>,
        under namespace:ModuleIdentifier,
        in group:DynamicResolutionGroup)
    {
        for (a, article):(Int32, SymbolGraph.Article<String>) in zip(
            self.current.graph.articles[range].indices,
            self.current.graph.articles[range])
        {
            guard let name:String = article.id
            else
            {
                //  TODO: This is a package-level article.
                continue
            }
            var record:Record.Master.Article = .init(id: self.current.zone + a,
                stem: .init(namespace, name))
            var resolver:DynamicResolver = .init(context: self.context,
                namespace: namespace,
                group: group)

            (record.overview, record.details) = resolver.link(article: article)

            self.projection.articles.append(record)
            self.errors += resolver.errors
        }
    }

    private mutating
    func link(decls range:ClosedRange<Int32>,
        under namespace:ModuleIdentifier,
        of culture:Unidoc.Scalar,
        in group:DynamicResolutionGroup)
    {
        for (d, ((symbol, node), conformances)):
            (Int32, ((Symbol.Decl, SymbolGraph.Node), Conformances)) in zip(range, zip(zip(
                self.current.graph.decls[range],
                self.current.graph.nodes[range]),
            self.conformances[range]))
        {
            let scope:Unidoc.Scalar? = self.current.scope(of: d)

            //  Ceremonial unwraps, should always succeed since we are only iterating
            //  over module ranges.
            guard   let decl:SymbolGraph.Decl = node.decl,
                    let d:Unidoc.Scalar = self.current.decls[d]
            else
            {
                continue
            }

            for f:Int32 in decl.features
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

            let superforms:[Unidoc.Scalar] = decl.superforms.compactMap
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

            var record:Record.Master.Decl = .init(id: d,
                phylum: decl.phylum,
                aperture: decl.aperture,
                route: decl.route,
                signature: decl.signature.map { self.current.decls[$0] },
                symbol: symbol,
                stem: .init(namespace, decl.path, orientation: decl.phylum.orientation),
                superforms: superforms,
                culture: culture,
                scope: scope.map { self.context.expand($0) } ?? [])

            if  let article:SymbolGraph.Article<Never> = decl.article
            {
                var resolver:DynamicResolver = .init(context: self.context,
                    namespace: namespace,
                    group: group,
                    scope: decl.phylum.scope(trimming: decl.path))

                (record.overview, record.details) = resolver.link(article: article)

                self.errors += resolver.errors
            }

            self.projection.decls.append(record)
        }
    }
}
