import HTTP
import Media
import UnidocQueries
import UnidocRecords
import URI

public
protocol VolumeRoot:StaticRoot
{
    static
    func response(
        vertex:consuming Unidoc.Vertex,
        groups:consuming [Unidoc.Group],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
}
extension VolumeRoot
{
    static
    subscript(names:Unidoc.VolumeMetadata) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(names.selector)")

        return uri
    }

    static
    subscript(names:Unidoc.VolumeMetadata, shoot:Unidoc.Shoot) -> URI
    {
        var uri:URI = Self[names]

        uri.path += shoot.stem
        uri["hash"] = shoot.hash?.description

        return uri
    }
}
