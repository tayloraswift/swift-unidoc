extension Unidoc
{
    @frozen public
    enum PackageMediaSetting:String, CaseIterable, Sendable
    {
        case media = "media-default"
        case media_gif = "media-gif"
        case media_jpg = "media-jpg"
        case media_png = "media-png"
        case media_svg = "media-svg"
        case media_webp = "media-webp"
    }
}
extension Unidoc.PackageMediaSetting:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension Unidoc.PackageMediaSetting:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
extension Unidoc.PackageMediaSetting
{
    var pattern:String
    {
        switch self
        {
        case .media:        "*"
        case .media_gif:    "*.gif"
        case .media_jpg:    "*.jpg, *.jpeg"
        case .media_png:    "*.png"
        case .media_svg:    "*.svg"
        case .media_webp:   "*.webp"
        }
    }
}
