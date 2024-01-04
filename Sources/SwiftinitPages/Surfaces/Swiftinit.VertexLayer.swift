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
    var docc:Swiftinit.Root { get }

    static
    var hist:Swiftinit.Root { get }
}
extension Swiftinit.VertexLayer
{
    private static
    subscript(volume:Unidoc.VolumeSelector, cdecl cdecl:Bool) -> URI
    {
        if  case _? = volume.version
        {
            Self.hist / "\(volume)"
        }
        else if cdecl
        {
            Self.docc / "\(volume)"
        }
        else
        {
            Self.docs / "\(volume)"
        }
    }

    static
    subscript(volume:Unidoc.VolumeMetadata) -> URI
    {
        Self[volume.selector, cdecl: false]
    }

    static
    subscript(volume:Unidoc.VolumeMetadata, route:Unidoc.Route) -> URI
    {
        var uri:URI = Self[volume.selector, cdecl: route.cdecl]

        uri.path += route.stem
        uri["hash"] = route.hash?.description

        return uri
    }
}
