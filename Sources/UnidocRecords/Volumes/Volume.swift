import JSON
import Unidoc

@frozen public
struct Volume:~Copyable
{
    public
    var latest:Unidoc.Edition?

    public
    var vertices:Vertices
    public
    var groups:Groups
    public
    var index:JSON
    public
    var trees:[TypeTree]
    public
    var meta:Metadata

    @inlinable public
    init(latest:Unidoc.Edition?,
        vertices:Vertices,
        groups:Groups,
        index:JSON,
        trees:[TypeTree],
        meta:Metadata)
    {
        self.latest = latest

        self.vertices = vertices
        self.groups = groups
        self.index = index
        self.trees = trees
        self.meta = meta
    }
}
extension Volume
{
    @inlinable public
    var edition:Unidoc.Edition { self.meta.id }
}
extension Volume
{
    @inlinable public
    var id:VolumeIdentifier { self.meta.symbol }
}
extension Volume
{
    @inlinable public
    var search:SearchIndex<VolumeIdentifier>
    {
        .init(id: self.id, json: self.index)
    }

    public
    func sitemap() -> Realm.Sitemap
    {
        let ignoredModules:Set<Unidoc.Scalar> = self.vertices.cultures.reduce(into: [])
        {
            switch $1.module.language
            {
            case nil, .swift?:  return
            case _?:            $0.insert($1.id)
            }
         }

        var elements:Realm.Sitemap.Elements = []
        for vertex:Vertex.Culture in self.vertices.cultures
        {
            elements.append(vertex.shoot)
        }
        for vertex:Vertex.Article in self.vertices.articles
        {
            elements.append(vertex.shoot)
        }
        for vertex:Vertex.Decl in self.vertices.decls
        {
            //  Skip C and C++ declarations.
            guard !ignoredModules.contains(vertex.culture),
            case .s = vertex.symbol.language
            else
            {
                continue
            }

            elements.append(vertex.shoot)
        }

        return .init(id: self.meta.id.package, elements: elements)
    }
}
