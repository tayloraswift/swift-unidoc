extension Unidoc.PackageMedia {
    enum FormKey: String, CaseIterable, Sendable {
        case media = "media-default"
        case media_gif = "media-gif"
        case media_jpg = "media-jpg"
        case media_png = "media-png"
        case media_svg = "media-svg"
        case media_webp = "media-webp"
    }
}
extension Unidoc.PackageMedia.FormKey: CustomStringConvertible {
    var description: String { self.rawValue }
}
extension Unidoc.PackageMedia.FormKey: LosslessStringConvertible {
    init?(_ description: String) { self.init(rawValue: description) }
}
extension Unidoc.PackageMedia.FormKey {
    var pattern: String {
        switch self {
        case .media:        "*"
        case .media_gif:    "*.gif"
        case .media_jpg:    "*.jpg, *.jpeg"
        case .media_png:    "*.png"
        case .media_svg:    "*.svg"
        case .media_webp:   "*.webp"
        }
    }
}
