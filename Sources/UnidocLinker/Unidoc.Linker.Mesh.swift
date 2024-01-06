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
    init(
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

        var snapshot:Unidoc.SnapshotDetails = .init(abi: linker.current.metadata.abi,
            requirements: linker.current.metadata.requirements,
            commit: linker.current.metadata.commit?.hash)
        var foreign:[Unidoc.ForeignVertex] = []

        //  Compute unweighted stats
        for (c, culture):(Int, SymbolGraph.Culture) in zip(cultures.indices,
            linker.current.cultures)
        {
            guard let range:ClosedRange<Int32> = culture.decls
            else
            {
                continue
            }
            for d:Int32 in range
            {
                if  let decl:SymbolGraph.Decl = linker.current.decls.nodes[d].decl
                {
                    let coverage:WritableKeyPath<Unidoc.Stats.Coverage, Int> = .classify(decl,
                        from: linker.current,
                        at: d)

                    let decl:WritableKeyPath<Unidoc.Stats.Decl, Int> = .classify(decl)

                    cultures[c].census.unweighted.coverage[keyPath: coverage] += 1
                    cultures[c].census.unweighted.decls[keyPath: decl] += 1

                    snapshot.census.unweighted.coverage[keyPath: coverage] += 1
                    snapshot.census.unweighted.decls[keyPath: decl] += 1
                }
            }
        }

        //  Create extension records, and compute weighted stats.
        snapshot.census.weighted = snapshot.census.unweighted
        for c:Int in cultures.indices
        {
            cultures[c].census.weighted = cultures[c].census.unweighted
        }

        for (signature, `extension`):(Unidoc.ExtensionSignature, Unidoc.Extension)
            in extensions.load()
        {
            for f:Unidoc.Scalar in `extension`.features
            {
                if  let decl:SymbolGraph.Decl = linker[f.package]?.decls[f.citizen]?.decl
                {
                    let bin:WritableKeyPath<Unidoc.Stats.Decl, Int> = .classify(decl)

                    cultures[signature.culture].census.weighted.decls[keyPath: bin] += 1
                    snapshot.census.weighted.decls[keyPath: bin] += 1
                }
            }

            let assembled:Unidoc.ExtensionGroup = `extension`.assemble(signature: signature,
                with: linker)

            defer
            {
                groups.extensions.append(assembled)
            }

            //  Compute shoots and create a foreign vertex, if this is the first extension for
            //  its scope.
            let next:Int = foreign.count
            if  let vertex:Unidoc.ForeignVertex = mapper.register(foreign: assembled.scope,
                    with: linker,
                    as: next)
            {
                foreign.append(vertex)
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

        let (trees, index):([Unidoc.TypeTree], JSON) = mapper.build(cultures: cultures)

        self.init(vertices: .init(
                articles: articles,
                cultures: cultures,
                decls: decls,
                files: files,
                products: (copy products),
                foreign: foreign,
                global: .init(id: linker.current.id.global, snapshot: snapshot)),
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
