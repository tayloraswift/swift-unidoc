import HTML

extension Unidoc {
    struct PackageMediaTool {
        let media: PackageMedia
    }
}
extension Unidoc.PackageMediaTool: HTML.OutputStreamable {
    static func += (form: inout HTML.ContentEncoder, self: Self) {
        form[.p] = """
        You can override the default media origins for local previewing. If the origin encodes
        a ref name, it will override all version-specific media paths for this package!
        """
        form[.dl] {
            for field: Unidoc.PackageMedia.FormKey in Unidoc.PackageMedia.FormKey.allCases {
                $0[.dt, .code] = field.pattern
                $0[.dd] {
                    $0[.input] {
                        $0.class = "full-width"
                        $0.type = "url"
                        $0.name = "\(field)"

                        $0.placeholder = "https://raw.githubusercontent.com/owner/repo/master"

                        switch field {
                        case .media:        $0.value = self.media.prefix
                        case .media_gif:    $0.value = self.media.gif
                        case .media_jpg:    $0.value = self.media.jpg
                        case .media_png:    $0.value = self.media.png
                        case .media_svg:    $0.value = self.media.svg
                        case .media_webp:   $0.value = self.media.webp
                        }
                    }
                }
            }
        }

        form[.button] { $0.class = "region" ; $0.type = "submit" } = "Apply"
    }
}
