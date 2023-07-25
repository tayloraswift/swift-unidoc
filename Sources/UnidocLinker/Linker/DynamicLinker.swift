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
    /// Protocol conformances for each declaration in the **current** snapshot.
    private
    let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Unidoc.Scalar>>

    private
    var extensions:Extensions
    public private(set)
    var projection:Records
    public private(set)
    var errors:[any DynamicLinkerError]

    private
    init(context:DynamicContext,
        conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Unidoc.Scalar>>,
        extensions:Extensions,
        errors:[any DynamicLinkerError])
    {
        self.context = context
        self.conformances = conformances

        self.extensions = extensions
        self.projection = .init(zone: .init(context.current.snapshot.zone,
            metadata: context.current.snapshot.metadata))
        self.errors = errors
    }
}
extension DynamicLinker
{
    public
    init(context:DynamicContext)
    {
        let groups:[DynamicClientGroup] = context.groups()

        var extensions:Extensions = .init(zone: context.current.zone)
        var errors:[any DynamicLinkerError] = []

        let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances> =
            context.current.graph.nodes.map
        {
            $1.extensions.isEmpty ? [:] : extensions.add($1.extensions,
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

        self.projection.extensions = self.extensions.records(context: context)
    }
}
extension DynamicLinker
{
    var current:SnapshotObject { self.context.current }
}
extension DynamicLinker
{
    private mutating
    func link(groups:[DynamicClientGroup])
    {
        for ((c, input), group):
            ((Int, SymbolGraph.Culture), DynamicClientGroup) in zip(zip(
                self.current.graph.cultures.indices,
                self.current.graph.cultures),
            groups)
        {
            let namespace:ModuleIdentifier = self.current.graph.namespaces[c]
            let culture:Unidoc.Scalar = self.current.zone + c * .module

            for decls:SymbolGraph.Namespace in input.namespaces
            {
                let namespace:ModuleIdentifier = self.current.graph.namespaces[decls.index]

                guard let n:Unidoc.Scalar = self.current.scalars.namespaces[decls.index]
                else
                {
                    self.errors.append(DroppedExtensionsError.decls(of: namespace,
                        count: decls.range.count))
                    continue
                }

                self.link(decls: decls.range,
                    under: (n, namespace),
                    of: culture,
                    in: group)
            }
            if  let articles:ClosedRange<Int32> = input.articles
            {
                self.link(articles: articles, under: (culture, namespace), in: group)
            }

            var record:Record.Master.Culture = .init(id: culture, module: input.module)

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
        under namespace:
        (
            scalar:Unidoc.Scalar,
            id:ModuleIdentifier
        ),
        in group:DynamicClientGroup)
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
                stem: .init(namespace.id, name),
                culture: namespace.scalar)
            var resolver:DynamicResolver = .init(context: self.context,
                namespace: namespace.id,
                group: group)

            (record.overview, record.details) = resolver.link(article: article)

            self.projection.articles.append(record)
            self.errors += resolver.errors
        }
    }

    private mutating
    func link(decls range:ClosedRange<Int32>,
        under namespace:
        (
            scalar:Unidoc.Scalar,
            id:ModuleIdentifier
        ),
        of culture:Unidoc.Scalar,
        in group:DynamicClientGroup)
    {
        for (d, ((symbol, node), conformances)):
            (Int32, ((Symbol.Decl, SymbolGraph.Node), ProtocolConformances<Unidoc.Scalar>)) in
            zip(range, zip(zip(
                    self.current.graph.decls[range],
                    self.current.graph.nodes[range]),
                self.conformances[range]))
        {
            let scope:Unidoc.Scalar? = self.current.scope(of: d)

            //  Ceremonial unwraps, should always succeed since we are only iterating
            //  over module ranges.
            guard   let decl:SymbolGraph.Decl = node.decl,
                    let d:Unidoc.Scalar = self.current.scalars.decls[d]
            else
            {
                continue
            }


            for f:Int32 in decl.features
            {
                //  The feature might have been declared in a different package!
                guard
                    let f:Unidoc.Scalar = self.current.scalars.decls[f],
                    let p:Unidoc.Scalar = self.context[f.package]?.scope(of: f)
                else
                {
                    continue
                }

                //  Now that we know the address of the feature’s original protocol,
                //  we can look up the constraints for the conformance(s) that
                //  conceived it.
                //
                //  This drops the feature if it belongs to a protocol whose
                //  conformance was not declared by any culture of the current
                //  package.
                for conformance:ProtocolConformance<Unidoc.Scalar> in conformances[to: p]
                {
                    let signature:ExtensionSignature = .init(
                        conditions: conformance.conditions,
                        culture: conformance.culture,
                        extends: d)
                    self.extensions[signature].features.append(f)
                }
            }

            let superforms:[Unidoc.Scalar] = decl.superforms.compactMap
            {
                if  let s:Unidoc.Scalar = self.current.scalars.decls[$0]
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
                customization: decl.customization,
                phylum: decl.phylum,
                route: decl.route,
                signature: decl.signature.map { self.current.scalars.decls[$0] },
                symbol: symbol,
                stem: .init(namespace.id, decl.path, orientation: decl.phylum.orientation),
                superforms: superforms,
                namespace: namespace.scalar,
                culture: culture,
                scope: scope.map { self.context.expand($0) } ?? [])

            if  let article:SymbolGraph.Article<Never> = decl.article
            {
                var resolver:DynamicResolver = .init(context: self.context,
                    namespace: namespace.id,
                    group: group,
                    scope: decl.phylum.scope(trimming: decl.path))

                (record.overview, record.details) = resolver.link(article: article)

                self.errors += resolver.errors
            }

            self.projection.decls.append(record)
        }
    }
}
