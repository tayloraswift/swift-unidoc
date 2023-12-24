import UnidocRecords
import URI

extension Swiftinit
{
    public
    typealias VolumeRoot = _SwiftinitVolumeRoot
}

/// The name of this protocol is ``Swiftinit.VolumeRoot``.
public
protocol _SwiftinitVolumeRoot:Swiftinit.StaticRoot
{
}
extension Swiftinit.VolumeRoot
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
