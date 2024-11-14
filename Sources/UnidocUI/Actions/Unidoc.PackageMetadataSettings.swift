import URI

extension Unidoc
{
    @frozen public
    enum PackageMetadataSettings:String, URI.Path.ComponentConvertible
    {
        case general
        case media
        case build
    }
}
