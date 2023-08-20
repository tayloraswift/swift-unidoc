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
    let diagnostics:DynamicLinkerDiagnostics

    private
    var extensions:Extensions

    /// Maps masters to groups.
    private
    var topics:[Int32: Unidoc.Scalar]
    private
    var topic:Unidoc.Counter<UnidocPlane.Topic>

    public private(set)
    var masters:[Record.Master]
    public private(set)
    var groups:[Record.Group]
    public
    let zone:Record.Zone

    private
    init(context:DynamicContext,
        conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Unidoc.Scalar>>,
        diagnostics:DynamicLinkerDiagnostics,
        extensions:Extensions)
    {
        self.context = context

        self.conformances = conformances
        self.diagnostics = diagnostics

        self.extensions = extensions

        self.topics = [:]
        self.topic = .init(zone: context.current.zone)

        self.masters = []
        self.groups = []
        self.zone = .init(context.current.snapshot.zone,
            metadata: context.current.snapshot.metadata)
    }
}
extension DynamicLinker
{
    public
    init(context:DynamicContext)
    {
        let clients:[DynamicClientGroup] = context.groups()

        let diagnostics:DynamicLinkerDiagnostics = .init()
        var extensions:Extensions = .init(zone: context.current.zone)

        let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances> =
            context.current.graph.decls.nodes.map
        {
            $1.extensions.isEmpty ? [:] : extensions.add($1.extensions,
                extending: $0,
                context: context,
                clients: clients,
                diagnostics: diagnostics)
        }

        self.init(context: context,
            conformances: conformances,
            diagnostics: diagnostics,
            extensions: extensions)

        self.link(clients: clients)

        //  Create file records.
        for (f, file):(Int32, Symbol.File) in zip(
            context.current.graph.files.indices,
            context.current.graph.files)
        {
            self.masters.append(.file(.init(id: context.current.zone + f, symbol: file)))
        }
        //  Create extension records.
        for (signature, `extension`):(ExtensionSignature, Extension) in self.extensions.sorted()
            where !`extension`.isEmpty
        {
            self.groups.append(.extension(.init(signature: signature,
                extension: `extension`,
                context: context)))
        }
    }
}
extension DynamicLinker
{
    public
    var errors:[any DynamicLinkerError] { self.diagnostics.errors }

    var current:SnapshotObject { self.context.current }
}
extension DynamicLinker
{
    private mutating
    func link(clients:[DynamicClientGroup])
    {
        //  First pass to create the topic records, which also populates topic memberships.
        for ((culture, input), clients):
            ((Int, SymbolGraph.Culture), DynamicClientGroup) in zip(zip(
                self.current.graph.cultures.indices,
                self.current.graph.cultures),
            clients)
        {
            let namespace:ModuleIdentifier = self.current.graph.namespaces[culture]
            let culture:Unidoc.Scalar = self.current.zone + culture * .module

            //  Create topic records.
            self.link(topics: input.topics, under: (culture, namespace), in: clients)
        }

        //  Second pass to create various master records, which reads from the ``topics``.
        for ((culture, input), clients):
            ((Int, SymbolGraph.Culture), DynamicClientGroup) in zip(zip(
                self.current.graph.cultures.indices,
                self.current.graph.cultures),
            clients)
        {
            let namespace:ModuleIdentifier = self.current.graph.namespaces[culture]
            let culture:Unidoc.Scalar = self.link(culture: input,
                under: namespace,
                index: culture,
                in: clients)

            //  Create decl records.
            for decls:SymbolGraph.Namespace in input.namespaces
            {
                let namespace:ModuleIdentifier = self.current.graph.namespaces[decls.index]

                guard let n:Unidoc.Scalar = self.current.scalars.namespaces[decls.index]
                else
                {
                    self.diagnostics.errors.append(DroppedExtensionsError.decls(of: namespace,
                        count: decls.range.count))
                    continue
                }

                self.link(decls: decls.range,
                    under: (n, namespace),
                    of: culture,
                    in: clients)
            }
            //  Create article records.
            if  let articles:ClosedRange<Int32> = input.articles
            {
                self.link(articles: articles, under: (culture, namespace), in: clients)
            }
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(topics:[SymbolGraph.Topic],
        under namespace:
        (
            scalar:Unidoc.Scalar,
            id:ModuleIdentifier
        ),
        in clients:DynamicClientGroup)
    {
        let resolver:DynamicResolver = .init(context: self.context,
            diagnostics: self.diagnostics,
            namespace: namespace.id,
            clients: clients)

        for topic:SymbolGraph.Topic in topics
        {
            var record:Record.Group.Topic = .init(id: self.topic.id(),
                culture: namespace.scalar,
                scope: namespace.scalar)

            (record.overview, record.members) = resolver.link(topic: topic)

            self.groups.append(.topic(record))

            for case .scalar(let master) in record.members
            {
                //  TODO: diagnose overlapping topics
                if  let local:Int32 = master - self.current.zone
                {
                    self.topics[local] = record.id
                }
            }
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(culture:SymbolGraph.Culture,
        under namespace:ModuleIdentifier,
        index c:Int,
        in clients:DynamicClientGroup) -> Unidoc.Scalar
    {
        let resolver:DynamicResolver = .init(context: self.context,
            diagnostics: self.diagnostics,
            namespace: namespace,
            clients: clients)

        var record:Record.Master.Culture = .init(id: self.current.zone + c * .module,
            module: culture.module,
            group: self.topics.removeValue(forKey: c * .module))

        if  let article:SymbolGraph.Article = culture.article
        {
            record.readme = article.file.map { self.current.zone + $0 }
            (record.overview, record.details) = resolver.link(article: article)
        }

        self.masters.append(.culture(record))
        return record.id
    }

    private mutating
    func link(articles range:ClosedRange<Int32>,
        under namespace:
        (
            scalar:Unidoc.Scalar,
            id:ModuleIdentifier
        ),
        in clients:DynamicClientGroup)
    {
        let resolver:DynamicResolver = .init(context: self.context,
            diagnostics: self.diagnostics,
            namespace: namespace.id,
            clients: clients)

        for (a, node):(Int32, SymbolGraph.ArticleNode) in zip(
            self.current.graph.articles.nodes[range].indices,
            self.current.graph.articles.nodes[range])
        {
            let symbol:Symbol.Article = self.current.graph.articles.symbols[a]
            var record:Record.Master.Article = .init(id: self.current.zone + a,
                stem: .init(namespace.id, symbol.name),
                culture: namespace.scalar,
                file: node.body.file.map { self.current.zone + $0 },
                headline: node.headline,
                group: self.topics.removeValue(forKey: a))

            (record.overview, record.details) = resolver.link(article: node.body)

            self.masters.append(.article(record))
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
        in clients:DynamicClientGroup)
    {
        for (d, ((symbol, node), conformances)):
            (Int32, ((Symbol.Decl, SymbolGraph.DeclNode), ProtocolConformances<Unidoc.Scalar>))
            in zip(range, zip(zip(
                    self.current.graph.decls.symbols[range],
                    self.current.graph.decls.nodes[range]),
                self.conformances[range]))
        {
            let group:Unidoc.Scalar? = self.topics.removeValue(forKey: d)
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

            let requirements:[Unidoc.Scalar] = decl.requirements.compactMap
            {
                self.current.scalars.decls[$0]
            }
            let superforms:[Unidoc.Scalar] = decl.superforms.compactMap
            {
                self.current.scalars.decls[$0]
            }
            for s:Unidoc.Scalar in superforms
            {
                let implicit:ExtensionSignature = .init(conditions: [],
                    culture: culture,
                    extends: s)

                self.extensions[implicit].subforms.append(d)
            }

            var record:Record.Master.Decl = .init(id: d,
                flags: .init(
                    phylum: decl.phylum,
                    kinks: decl.kinks,
                    route: decl.route),
                signature: decl.signature.map { self.current.scalars.decls[$0] },
                symbol: symbol,
                stem: .init(namespace.id, decl.path, orientation: decl.phylum.orientation),
                requirements: self.context.sort(lexically: requirements),
                superforms: self.context.sort(lexically: superforms),
                namespace: namespace.scalar,
                culture: culture,
                scope: scope.map { self.context.expand($0) } ?? [],
                file: decl.location.map { self.current.zone + $0.file },
                position: decl.location?.position,
                group: group)

            if  let article:SymbolGraph.Article = decl.article
            {
                let resolver:DynamicResolver = .init(context: self.context,
                    diagnostics: self.diagnostics,
                    namespace: namespace.id,
                    clients: clients,
                    scope: decl.phylum.scope(trimming: decl.path))

                (record.overview, record.details) = resolver.link(article: article)
            }

            self.masters.append(.decl(record))
        }
    }
}
