import JSONDecoding
import JSONEncoding

extension PackageManifest
{
    @frozen public
    enum LibraryType:String, Hashable, Equatable, Sendable
    {
        case automatic
        case dynamic
        case `static`
    }
}
extension PackageManifest.LibraryType:JSONDecodable, JSONEncodable
{
}
