import JSON
import ModuleGraphs
import Unidoc

@frozen public
struct Volume:~Copyable
{
    public
    var latest:Unidoc.Zone?

    public
    var vertices:[Vertex]
    public
    var groups:[Group]
    public
    var trees:[TypeTree]
    public
    var index:JSON
    public
    var meta:Meta

    @inlinable public
    init(latest:Unidoc.Zone?,
        vertices:[Vertex],
        groups:[Group],
        trees:[TypeTree],
        index:JSON,
        meta:Meta)
    {
        self.latest = latest

        self.vertices = vertices
        self.groups = groups
        self.trees = trees
        self.index = index
        self.meta = meta
    }
}
extension Volume
{
    @inlinable public
    var edition:Unidoc.Zone { self.meta.id }
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
    func siteMap() -> SiteMap<PackageIdentifier>
    {
        var lines:[UInt8] = []
        //  Reverse, because C modules tend to appear in the beginning of the list, and
        //  we want to prioritize Swift modules.
        for vertex:Vertex in self.vertices.reversed()
        {
            switch vertex
            {
            case .culture(let vertex):
                vertex.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .article(let vertex):
                vertex.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .decl(let vertex):
                vertex.shoot.serialize(into: &lines) ; lines.append(0x0A)

            case .file, .foreign, .global:
                continue
            }
        }

        return .init(id: self.meta.symbol.package, lines: lines)
    }
}
