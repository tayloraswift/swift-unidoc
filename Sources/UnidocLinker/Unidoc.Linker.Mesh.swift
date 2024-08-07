import BSON
import JSON
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.Linker
{
    @frozen public
    struct Mesh:~Copyable
    {
        public
        var vertices:Unidoc.Volume.Vertices
        public
        var groups:Unidoc.Volume.Groups
        public
        var index:JSON
        public
        var trees:[Unidoc.TypeTree]
        public
        var products:[Unidoc.Noun]
        public
        var cultures:[Unidoc.Noun]

        private
        init(vertices:Unidoc.Volume.Vertices,
            groups:Unidoc.Volume.Groups,
            index:JSON,
            trees:[Unidoc.TypeTree],
            products:[Unidoc.Noun],
            cultures:[Unidoc.Noun])
        {
            self.vertices = vertices
            self.groups = groups
            self.index = index
            self.trees = trees
            self.products = products
            self.cultures = cultures
        }
    }
}
extension Unidoc.Linker.Mesh
{
    init(around landing:consuming Unidoc.LandingVertex,
        conformances:consuming Unidoc.Linker.Table<Unidoc.Conformers>,
        extensions:consuming Unidoc.Linker.Table<Unidoc.Extension>,
        products:consuming [Unidoc.ProductVertex],
        cultures:consuming [Unidoc.CultureVertex],
        articles:consuming [Unidoc.ArticleVertex],
        decls:consuming [Unidoc.DeclVertex],
        groups:consuming Unidoc.Volume.Groups,
        linker:borrowing Unidoc.Linker)
    {
        var cultures:[Unidoc.CultureVertex] = cultures

        let articles:[Unidoc.ArticleVertex] = articles
        let decls:[Unidoc.DeclVertex] = decls

        var mapper:Unidoc.Linker.TreeMapper = .init(zone: linker.current.id)
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

        self.init(vertices: .init(
                articles: articles,
                cultures: cultures,
                decls: decls,
                files: files,
                products: copy products,
                foreign: foreign,
                landing: landing),
            groups: groups,
            index: index,
            trees: trees,
            products: products.map
            {
                .init(shoot: $0.shoot, type: .stem(.package, nil))
            }
                .sorted
            {
                $0.shoot < $1.shoot
            },
            cultures: cultures.map
            {
                .init(shoot: $0.shoot, type: .stem(.package, nil))
            }
                .sorted
            {
                $0.shoot < $1.shoot
            })
    }
}
