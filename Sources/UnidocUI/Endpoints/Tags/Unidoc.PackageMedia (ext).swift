import Symbols
import UnidocRecords

extension Unidoc.PackageMedia {
    public init?(parameters form: borrowing [String: String]) {
        guard
        let prefix: String = form["\(FormKey.media)"],
        let gif: String = form["\(FormKey.media_gif)"],
        let jpg: String = form["\(FormKey.media_jpg)"],
        let png: String = form["\(FormKey.media_png)"],
        let svg: String = form["\(FormKey.media_svg)"],
        let webp: String = form["\(FormKey.media_webp)"] else {
            return nil
        }

        self.init(
            prefix: prefix.isEmpty ? nil : prefix,
            gif: gif.isEmpty ? nil : gif,
            jpg: jpg.isEmpty ? nil : jpg,
            png: png.isEmpty ? nil : png,
            svg: svg.isEmpty ? nil : svg,
            webp: webp.isEmpty ? nil : webp
        )
    }
}
extension Unidoc.PackageMedia {
    func link(media file: Symbol.File) -> String? {
        //  Files that lack a valid extension will not carry the correct `Content-Type`
        //  header, and won’t display correctly in the browser. There is no simple way to
        //  override this behavior, so files will just need to have the correct extension.
        guard
        let type: Substring = file.type else {
            return nil
        }

        let prefix: String?
        switch type {
        case "gif":     prefix = self.gif
        case "jpg":     prefix = self.jpg
        case "jpeg":    prefix = self.jpg
        case "png":     prefix = self.png
        case "svg":     prefix = self.svg
        case "webp":    prefix = self.webp
        default:        return nil
        }

        guard
        let prefix: String = prefix ?? self.prefix else {
            return nil
        }

        return "\(prefix)/\(file)"
    }
}
