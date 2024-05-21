import BSON
import JSON
import Symbols
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct Volume:~Copyable
    {
        public
        var latest:Edition?

        public
        var metadata:VolumeMetadata
        public
        var vertices:Vertices
        public
        var groups:Groups
        public
        var index:JSON
        public
        var trees:[TypeTree]

        @inlinable public
        init(latest:Edition?,
            metadata:VolumeMetadata,
            vertices:Vertices,
            groups:Groups,
            index:JSON,
            trees:[TypeTree])
        {
            self.latest = latest

            self.metadata = metadata
            self.vertices = vertices
            self.groups = groups
            self.index = index
            self.trees = trees
        }
    }
}
extension Unidoc.Volume
{
    @inlinable public
    var edition:Unidoc.Edition { self.metadata.id }
}
extension Unidoc.Volume
{
    @inlinable public
    var id:Symbol.Edition { self.metadata.symbol }
}
extension Unidoc.Volume
{
    public
    func sitemap() -> Unidoc.Sitemap
    {
        /// At the moment, we can’t fully rely on the `language` property of the decl flags,
        /// due to backwards compatibility with the old symbol graph format.
        let ignoredModules:Set<Unidoc.Scalar> = self.vertices.cultures.reduce(into: [])
        {
            switch $1.module.language
            {
            case nil, .swift?:  return
            case _?:            $0.insert($1.id)
            }
        }

        let lines:BSON.BinaryView<ArraySlice<UInt8>> = .init
        {
            for vertex:Unidoc.CultureVertex in self.vertices.cultures
            {
                $0 += vertex.shoot
                $0.append(Unidoc.Sitemap.Elements.separator)
            }
            for vertex:Unidoc.ArticleVertex in self.vertices.articles
            {
                $0 += vertex.shoot
                $0.append(Unidoc.Sitemap.Elements.separator)
            }
            for vertex:Unidoc.DeclVertex in self.vertices.decls
            {
                //  Skip C and C++ declarations.
                guard !ignoredModules.contains(vertex.culture),
                case .swift = vertex.flags.language,
                case .s = vertex.symbol.language
                else
                {
                    continue
                }

                $0 += vertex.shoot
                $0.append(Unidoc.Sitemap.Elements.separator)
            }
        }

        return .init(id: self.metadata.id.package, elements: .init(bytes: lines.bytes))
    }
}
