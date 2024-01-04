import Swiftinit
import UnidocRecords
import URI

extension Swiftinit
{
    public
    typealias VertexLayer = _SwiftinitVertexLayer
}

/// The name of this protocol is ``Swiftinit.VertexLayer``.
public
protocol _SwiftinitVertexLayer
{
    static
    var docs:Swiftinit.Root { get }

    static
    var hist:Swiftinit.Root { get }
}
extension Swiftinit.VertexLayer
{
    static
    subscript(volume:Unidoc.VolumeMetadata) -> URI
    {
        let volume:Unidoc.VolumeSelector = volume.selector

        if  case nil = volume.version
        {
            return Self.docs / "\(volume)"
        }
        else
        {
            return Self.hist / "\(volume)"
        }
    }

    static
    subscript(volume:Unidoc.VolumeMetadata, route:Unidoc.Route) -> URI
    {
        var uri:URI = Self[volume]

        uri.path += route.stem
        uri["hash"] = route.hash?.description

        return uri
    }
}
