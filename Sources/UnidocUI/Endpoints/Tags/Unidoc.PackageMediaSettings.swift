import HTML

extension Unidoc
{
    struct PackageMediaSettings
    {
        let package:Unidoc.PackageMetadata
    }
}
extension Unidoc.PackageMediaSettings:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.input]
        {
            $0.type = "hidden"
            $0.name = "package"
            $0.value = "\(self.package.id)"
        }

        form[.p] = """
        You can override the default media origins for local previewing. If the origin encodes
        a ref name, it will override all version-specific media paths for this package!
        """
        form[.dl]
        {
            for setting:Unidoc.PackageMediaSetting in Unidoc.PackageMediaSetting.allCases
            {
                $0[.dt, .code] = setting.pattern
                $0[.dd]
                {
                    $0[.input]
                    {
                        $0.class = "full-width"
                        $0.type = "url"
                        $0.name = "\(setting)"

                        $0.placeholder = "https://raw.githubusercontent.com/owner/repo/master"

                        switch setting
                        {
                        case .media:        $0.value = self.package.media?.prefix
                        case .media_gif:    $0.value = self.package.media?.gif
                        case .media_jpg:    $0.value = self.package.media?.jpg
                        case .media_png:    $0.value = self.package.media?.png
                        case .media_svg:    $0.value = self.package.media?.svg
                        case .media_webp:   $0.value = self.package.media?.webp
                        }
                    }
                }
            }
        }

        form[.button]
        {
            $0.class = "area"
            $0.type = "submit"
        } = "Apply"
    }
}
