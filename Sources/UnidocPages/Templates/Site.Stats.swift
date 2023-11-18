import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Site
{
    @frozen public
    enum Stats
    {
    }
}
extension Site.Stats:StaticRoot
{
    @inlinable public static
    var root:String { "stats" }
}
extension Site.Stats:VolumeRoot
{
    public static
    func response(
        vertex:consuming Volume.Vertex,
        groups:consuming [Volume.Group],
        tree:consuming Volume.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        .error("")
    }
}
