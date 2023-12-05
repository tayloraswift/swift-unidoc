import JSON
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension DynamicLinker
{
    @frozen public
    struct Mesh:~Copyable
    {
        public
        var vertices:Volume.Vertices
        public
        var groups:Volume.Groups
        public
        var index:JSON
        public
        var trees:[Volume.TypeTree]
        public
        var tree:[Volume.Noun]

        private
        init(vertices:Volume.Vertices,
            groups:Volume.Groups,
            index:JSON,
            trees:[Volume.TypeTree],
            tree:[Volume.Noun])
        {
            self.vertices = vertices
            self.groups = groups
            self.index = index
            self.trees = trees
            self.tree = tree
        }
    }
}
extension DynamicLinker.Mesh
{
    init(
        extensions:borrowing DynamicLinker.Extensions,
        articles:consuming [Volume.Vertex.Article],
        cultures:consuming [Volume.Vertex.Culture],
        decls:consuming [Volume.Vertex.Decl],
        groups:consuming Volume.Groups,
        context:borrowing DynamicContext)
    {
        var cultures:[Volume.Vertex.Culture] = cultures

        let articles:[Volume.Vertex.Article] = articles
        let decls:[Volume.Vertex.Decl] = decls

        var mapper:DynamicLinker.TreeMapper = .init(zone: context.current.id)
        for vertex:Volume.Vertex.Article in articles
        {
            mapper.add(vertex)
        }
        for vertex:Volume.Vertex.Decl in decls
        {
            mapper.add(vertex)
        }

        var snapshot:Volume.SnapshotDetails = .init(abi: context.current.metadata.abi,
            requirements: context.current.metadata.requirements)
        var foreign:[Volume.Vertex.Foreign] = []

        //  Compute shoots for out-of-package extended types.
        for d:Int32 in context.current.decls.nodes.indices
        {
            if  case nil = context.current.decls.nodes[d].decl,
                let f:Unidoc.Scalar = context.current.scalars.decls[d]
            {
                foreign.append(mapper.register(foreign: f, with: context))
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

        for (signature, `extension`):
            (DynamicLinker.ExtensionSignature, DynamicLinker.Extension) in extensions.sorted()
            where !`extension`.isEmpty
        {
            for f:Unidoc.Scalar in `extension`.features
            {
                if  let decl:SymbolGraph.Decl = context[f.package]?.decls[f.citizen]?.decl
                {
                    let bin:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[signature.culture].census.weighted.decls[keyPath: bin] += 1
                    snapshot.census.weighted.decls[keyPath: bin] += 1
                }
            }

            let assembled:Volume.Group.Extension = context.assemble(
                extension: `extension`,
                signature: signature)

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

        //  Create file vertices.
        let files:[Volume.Vertex.File] = zip(
            context.current.files.indices,
            context.current.files)
            .map
        {
            .init(id: context.current.id + $0, symbol: $1)
        }

        let (trees, index):([Volume.TypeTree], JSON) = mapper.build(cultures: cultures)

        self.init(vertices: .init(
                articles: articles,
                cultures: cultures,
                decls: decls,
                files: files,
                foreign: foreign,
                global: .init(id: context.current.id.global, snapshot: snapshot)),
            groups: groups,
            index: index,
            trees: trees,
            tree: cultures.map
            {
                .init(shoot: $0.shoot, style: .stem(.package))
            }
                .sorted
            {
                $0.shoot < $1.shoot
            })
    }
}
