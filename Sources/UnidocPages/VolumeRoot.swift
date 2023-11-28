import HTTP
import Media
import UnidocQueries
import UnidocRecords
import UnidocSelectors
import URI

public
protocol VolumeRoot:StaticRoot
{
    static
    func response(
        vertex:consuming Volume.Vertex,
        groups:consuming [Volume.Group],
        tree:consuming Volume.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
}
extension VolumeRoot
{
    static
    subscript(names:Volume.Meta) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(names.selector)")

        return uri
    }

    static
    subscript(names:Volume.Meta, shoot:Volume.Shoot) -> URI
    {
        var uri:URI = Self[names]

        uri.path += shoot.stem
        uri["hash"] = shoot.hash?.description

        return uri
    }
}
