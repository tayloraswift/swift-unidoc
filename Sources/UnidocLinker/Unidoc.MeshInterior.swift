import JSON
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct MeshInterior
    {
        var vertices:Mesh.Vertices
        var groups:Mesh.Groups
        var index:JSON
        var trees:[TypeTree]
        var redirects:[RedirectVertex]

        private
        init(vertices:Mesh.Vertices,
            groups:Mesh.Groups,
            index:JSON,
            trees:[TypeTree],
            redirects:[RedirectVertex])
        {
            self.vertices = vertices
            self.groups = groups
            self.index = index
            self.trees = trees
            self.redirects = redirects
        }
    }
}
extension Unidoc.MeshInterior
{
    init(primary metadata:SymbolGraphMetadata,
        pinned:[Unidoc.Package],
        with linker:inout Unidoc.LinkerContext)
    {
        let current:Unidoc.Edition = linker.current.id
        let symbols:(linkable:Int, linked:Int) = linker.current.scalars.decls.reduce(
            into: (0, 0))
        {
            guard
            let id:Unidoc.Scalar = $1
            else
            {
                $0.linkable += 1
                return
            }

            if  id.edition != current
            {
                $0.linkable += 1
                $0.linked += 1
            }
        }

        let landingVertex:Unidoc.LandingVertex = .init(id: current.global,
            snapshot: .init(abi: metadata.abi,
                latestManifest: metadata.tools,
                extraManifests: metadata.manifests,
                requirements: metadata.requirements,
                commit: metadata.commit?.sha1,
                symbolsLinkable: symbols.linkable,
                symbolsLinked: symbols.linked),
            packages: pinned)

        var tables:Unidoc.LinkerTables = .init(linker: consume linker)

        let conformances:Unidoc.LinkerTable<Unidoc.Conformers> = tables.linkConformingTypes()
        let products:[Unidoc.ProductVertex] = tables.linkProducts()

        tables.linkCurations()
        tables.linkIntrinsics()

        let decls:[Unidoc.DeclVertex] = tables.linkDecls()
        let articles:[Unidoc.ArticleVertex] = tables.linkArticles()
        let cultures:[Unidoc.CultureVertex] = tables.linkCultures()
        let redirects:[Unidoc.RedirectVertex] = tables.linkRedirects()

        let extensions:Unidoc.LinkerTable<Unidoc.Extension> = tables.extensions
        let groups:Unidoc.Mesh.Groups = tables.groups

        linker = (consume tables).linker

        self.init(around: landingVertex,
            conformances: conformances,
            extensions: extensions,
            redirects: redirects,
            products: products,
            cultures: cultures,
            articles: articles,
            decls: decls,
            groups: groups,
            linker: linker)
    }

    private
    init(around landing:consuming Unidoc.LandingVertex,
        conformances:consuming Unidoc.LinkerTable<Unidoc.Conformers>,
        extensions:consuming Unidoc.LinkerTable<Unidoc.Extension>,
        redirects:consuming [Unidoc.RedirectVertex],
        products:consuming [Unidoc.ProductVertex],
        cultures:consuming [Unidoc.CultureVertex],
        articles:consuming [Unidoc.ArticleVertex],
        decls:consuming [Unidoc.DeclVertex],
        groups:consuming Unidoc.Mesh.Groups,
        linker:borrowing Unidoc.LinkerContext)
    {
        var cultures:[Unidoc.CultureVertex] = cultures

        let articles:[Unidoc.ArticleVertex] = articles
        let decls:[Unidoc.DeclVertex] = decls

        var mapper:Unidoc.TreeMapper = .init(zone: linker.current.id)
        for vertex:Unidoc.ArticleVertex in articles
        {
            mapper.add(vertex)
        }
        for vertex:Unidoc.DeclVertex in decls
        {
            mapper.add(vertex)
        }

        var foreign:[Unidoc.ForeignVertex] = []

        var census:Unidoc.Census.Enumerators = .init(cultures: cultures.count)

        //  Compute unweighted stats
        for (c, culture):(Int, SymbolGraph.Culture) in zip(cultures.indices,
            linker.current.cultures)
        {
            guard
            let range:ClosedRange<Int32> = culture.decls
            else
            {
                continue
            }
            for d:Int32 in range
            {
                if  let decl:SymbolGraph.Decl = linker.current.decls.nodes[d].decl
                {
                    census.count(citizen: decl, culture: c, _from: linker.current, _at: d)
                }
            }
        }

        //  We do this here and not dynamically in the loop after it for several reasons.
        //
        //  1.  Some of the extensions might be synthetic, and if we mirror them, they might
        //      not have the correct hash disambiguator settings. For example, a mirror vertex
        //      generated from a synthetic extension could collide with a local vertex that
        //      has its route set to `unhashed`.
        //
        //  2.  We often have multiple extensions attached to the same extended declaration,
        //      and we would have to de-duplicate them when creating mirror vertices.
        //
        //  3.  We really want to avoid doing any package-wide URL computation in the dynamic
        //      linker, because that could be done by the static linker, and we would rather
        //      hew to the URLs that the static linker computed.
        for (n, node):(Int32, SymbolGraph.DeclNode) in zip(
            linker.current.decls.nodes.indices,
            linker.current.decls.nodes)
        {
            let next:Int = foreign.count
            if  case nil = node.decl,
                let vertex:Unidoc.Scalar = linker.current.scalars.decls[n],
                let mirror:Unidoc.ForeignVertex = mapper.register(foreign: vertex,
                    with: linker,
                    as: next)
            {
                foreign.append(mirror)
            }
        }

        for (signature, `extension`):(Unidoc.ExtensionSignature, Unidoc.Extension)
            in extensions.load()
        {
            for f:Unidoc.Scalar in `extension`.features
            {
                if  let decl:SymbolGraph.Decl = linker[f.package]?.decls[f.citizen]?.decl
                {
                    census.count(feature: decl, culture: signature.culture)
                }
            }

            let assembled:Unidoc.ExtensionGroup = `extension`.assemble(signature: signature,
                with: linker)

            defer
            {
                groups.extensions.append(assembled)
            }

            //  Extensions that only contain subforms are not interesting.
            if  assembled.nested.isEmpty,
                assembled.features.isEmpty,
                assembled.conformances.isEmpty
            {
                continue
            }

            mapper.update(with: assembled)
        }
        for (signature, conformers):(Unidoc.ConformanceSignature, Unidoc.Conformers)
            in conformances.load()
        {
            let assembled:Unidoc.ConformerGroup = conformers.assemble(signature: signature,
                with: linker)

            defer
            {
                groups.conformers.append(assembled)
            }

            //  FIXME: This has a small chance of causing URL collisions, because these are
            //  technically synthetic extensions, and generating mirror vertices from synthetic
            //  extensions is evil. Instead, the static linker should be tracking the upstream
            //  protocols as symbol graph nodes, and we should only be generating mirror
            //  vertices here as a backward compatibility measure for older symbol graphs.
            let next:Int = foreign.count
            if  let vertex:Unidoc.ForeignVertex = mapper.register(foreign: assembled.scope,
                    with: linker,
                    as: next)
            {
                foreign.append(vertex)
            }
        }

        //  Create file vertices.
        let files:[Unidoc.FileVertex] = zip(
            linker.current.files.indices,
            linker.current.files)
            .map
        {
            .init(id: linker.current.id + $0, symbol: $1)
        }

        //  Integrate stats.
        landing.snapshot.census = .init(from: census.combined)
        for c:Int in cultures.indices
        {
            cultures[c].census = .init(from: census.cultures[c])
        }

        let (trees, index):([Unidoc.TypeTree], JSON) = mapper.build(cultures: cultures)

        self.init(vertices: .init(landing: landing,
                articles: articles,
                cultures: cultures,
                decls: decls,
                files: files,
                products: copy products,
                foreign: foreign),
            groups: groups,
            index: index,
            trees: trees,
            redirects: redirects)
    }
}
