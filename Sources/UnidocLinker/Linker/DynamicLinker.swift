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
    let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>>
    private
    let diagnostics:DynamicLinkerDiagnostics

    private
    var extensions:Extensions

    /// Maps vertices to groups.
    private
    var memberships:[Int32: Unidoc.Scalar]
    private
    var next:
    (
        autogroup:Unidoc.Counter<UnidocPlane.Autogroup>,
        topic:Unidoc.Counter<UnidocPlane.Topic>
    )

    public private(set)
    var vertices:[Volume.Vertex]
    public private(set)
    var groups:[Volume.Group]
    public private(set)
    var meta:Volume.Meta.LinkDetails

    private
    init(context:DynamicContext,
        conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>>,
        diagnostics:DynamicLinkerDiagnostics,
        extensions:Extensions)
    {
        self.context = context

        self.conformances = conformances
        self.diagnostics = diagnostics

        self.extensions = extensions

        self.memberships = [:]

        self.next.autogroup = .init(zone: context.current.edition)
        self.next.topic = .init(zone: context.current.edition)

        self.vertices = []
        self.groups = []
        self.meta = .init(abi: context.current.metadata.abi,
            requirements: context.current.metadata.requirements)
    }
}
extension DynamicLinker
{
    public
    init(context:DynamicContext)
    {
        let clients:[DynamicClientGroup] = context.groups()

        let diagnostics:DynamicLinkerDiagnostics = .init()
        var extensions:Extensions = .init(zone: context.current.edition)

        let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>> =
            context.current.decls.nodes.map
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

        self.autogroup()

        var cultures:[Volume.Vertex.Culture] = self.link(clients: clients)

        defer
        {
            self.vertices.append(.meta(.init(id: context.current.edition.meta)))
            for culture:Volume.Vertex.Culture in cultures
            {
                self.vertices.append(.culture(culture))
            }
        }

        //  Compute unweighted stats
        for (c, culture):(Int, SymbolGraph.Culture) in zip(cultures.indices,
            context.current.cultures)
        {
            guard let range:ClosedRange<Int32> = culture.decls
            else
            {
                continue
            }
            for d:Int32 in range
            {
                if  let decl:SymbolGraph.Decl = context.current.decls.nodes[d].decl
                {
                    let coverage:WritableKeyPath<Volume.Stats.Coverage, Int> = .classify(decl,
                        from: context.current,
                        at: d)

                    let decl:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[c].census.unweighted.coverage[keyPath: coverage] += 1
                    cultures[c].census.unweighted.decls[keyPath: decl] += 1

                    self.meta.census.unweighted.coverage[keyPath: coverage] += 1
                    self.meta.census.unweighted.decls[keyPath: decl] += 1
                }
            }
        }

        //  Create file records.
        for (f, file):(Int32, Symbol.File) in zip(
            context.current.files.indices,
            context.current.files)
        {
            self.vertices.append(.file(.init(id: context.current.edition + f, symbol: file)))
        }

        //  Create extension records, and compute weighted stats.
        self.meta.census.weighted = self.meta.census.unweighted
        for c:Int in cultures.indices
        {
            cultures[c].census.weighted = cultures[c].census.unweighted
        }

        for (signature, `extension`):(ExtensionSignature, Extension) in self.extensions.sorted()
            where !`extension`.isEmpty
        {
            self.groups.append(.extension(context.assemble(extension: `extension`,
                signature: signature)))

            for f:Unidoc.Scalar in `extension`.features
            {
                if  let decl:SymbolGraph.Decl = context[f.package]?.decls[f.citizen]?.decl
                {
                    let bin:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[signature.culture].census.weighted.decls[keyPath: bin] += 1
                    self.meta.census.weighted.decls[keyPath: bin] += 1
                }
            }
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
    func autogroup()
    {
        //  Create a synthetic topic containing all the cultures. This will become a “See Also”
        //  for their module pages, unless they belong to a custom topic group.
        let cultures:Volume.Group.Automatic = .init(id: self.next.autogroup.id(),
            scope: self.current.edition.meta,
            members: self.current.cultures.indices.sorted
            {
                self.current.namespaces[$0] <
                self.current.namespaces[$1]
            }
            .map
            {
                self.current.edition + $0 * .module
            })

        self.groups.append(.automatic(cultures))

        for c:Int in self.current.cultures.indices
        {
            self.memberships[c * .module] = cultures.id
        }
    }
    private mutating
    func link(clients:[DynamicClientGroup]) -> [Volume.Vertex.Culture]
    {
        //  First pass to create the topic records, which also populates topic memberships.
        for ((culture, input), clients):((Int, SymbolGraph.Culture), DynamicClientGroup)
            in zip(zip(
                self.current.cultures.indices,
                self.current.cultures),
            clients)
        {
            //  Create topic records.
            self.link(topics: input.topics,
                of: (culture, self.current.namespaces[culture]),
                in: clients)
        }

        //  Second pass to create various master records, which reads from the ``topics``.
        var cultures:[Volume.Vertex.Culture] = []
            cultures.reserveCapacity(self.current.cultures.count)

        for ((culture, input), clients):
            ((Int, SymbolGraph.Culture), DynamicClientGroup) in zip(zip(
                self.current.cultures.indices,
                self.current.cultures),
            clients)
        {
            let namespace:ModuleIdentifier = self.current.namespaces[culture]
            let record:Volume.Vertex.Culture = self.link(culture: input,
                named: namespace,
                at: culture,
                in: clients)

            //  Create decl records.
            for decls:SymbolGraph.Namespace in input.namespaces
            {
                let namespace:ModuleIdentifier = self.current.namespaces[decls.index]

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
                self.link(articles: articles, of: (culture, namespace), in: clients)
            }

            cultures.append(record)
        }

        return cultures
    }
}
extension DynamicLinker
{
    private mutating
    func link(topics:[SymbolGraph.Topic],
        of culture:(index:Int, id:ModuleIdentifier),
        in clients:DynamicClientGroup)
    {
        let resolver:DynamicResolver = .init(context: self.context,
            diagnostics: self.diagnostics,
            namespace: culture.id,
            clients: clients)

        let n:Unidoc.Scalar = self.current.edition + culture.index

        for topic:SymbolGraph.Topic in topics
        {
            var record:Volume.Group.Topic = .init(id: self.next.topic.id(),
                culture: n,
                scope: n)

            (record.overview, record.members) = resolver.link(topic: topic)

            self.groups.append(.topic(record))

            for case .scalar(let master) in record.members
            {
                //  This may replace a synthesized topic.
                if  let local:Int32 = master - self.current.edition
                {
                    self.memberships[local] = record.id
                }
            }
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(culture:SymbolGraph.Culture,
        named name:ModuleIdentifier,
        at index:Int,
        in clients:DynamicClientGroup) -> Volume.Vertex.Culture
    {
        let resolver:DynamicResolver = .init(context: self.context,
            diagnostics: self.diagnostics,
            namespace: name,
            clients: clients)

        let scalar:Unidoc.Scalar = self.current.edition + index
        var record:Volume.Vertex.Culture = .init(id: scalar,
            module: culture.module,
            group: self.memberships.removeValue(forKey: scalar.citizen))

        if  let article:SymbolGraph.Article = culture.article
        {
            record.readme = article.file.map { self.current.edition + $0 }
            (record.overview, record.details) = resolver.link(article: article)
        }

        return record
    }

    private mutating
    func link(articles range:ClosedRange<Int32>,
        of culture:(index:Int, id:ModuleIdentifier),
        in clients:DynamicClientGroup)
    {
        let resolver:DynamicResolver = .init(context: self.context,
            diagnostics: self.diagnostics,
            namespace: culture.id,
            clients: clients)

        for (a, node):(Int32, SymbolGraph.ArticleNode) in zip(
            self.current.articles.nodes[range].indices,
            self.current.articles.nodes[range])
        {
            let symbol:Symbol.Article = self.current.articles.symbols[a]
            var record:Volume.Vertex.Article = .init(id: self.current.edition + a,
                stem: .init(culture.id, symbol.name),
                culture: self.current.edition + culture.index,
                file: node.body.file.map { self.current.edition + $0 },
                headline: node.headline,
                group: self.memberships.removeValue(forKey: a))

            (record.overview, record.details) = resolver.link(article: node.body)

            self.vertices.append(.article(record))
        }
    }

    private mutating
    func link(decls range:ClosedRange<Int32>,
        under namespace:(scalar:Unidoc.Scalar, id:ModuleIdentifier),
        of culture:Int,
        in clients:DynamicClientGroup)
    {
        for (d, ((symbol, node), conformances)):
            (Int32, ((Symbol.Decl, SymbolGraph.DeclNode), ProtocolConformances<Int>))
            in zip(range, zip(zip(
                    self.current.decls.symbols[range],
                    self.current.decls.nodes[range]),
                self.conformances[range]))
        {
            let group:Unidoc.Scalar? = self.memberships.removeValue(forKey: d)
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
                for conformance:ProtocolConformance<Int> in conformances[to: p]
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

            var record:Volume.Vertex.Decl = .init(id: d,
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
                culture: self.current.edition + culture,
                scope: scope.map { self.context.expand($0) } ?? [],
                file: decl.location.map { self.current.edition + $0.file },
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

            self.vertices.append(.decl(record))
        }
    }
}
