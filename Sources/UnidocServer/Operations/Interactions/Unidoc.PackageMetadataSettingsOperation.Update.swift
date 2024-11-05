import URI

extension Unidoc.PackageMetadataSettingsOperation
{
    enum Update
    {
        case build(Unidoc.BuildTemplate)
        case media(Unidoc.PackageMedia)
    }
}
extension Unidoc.PackageMetadataSettingsOperation.Update
{
    init?(type:Unidoc.PackageMetadataSettings, form:URI.Query)
    {
        let form:[String: String] = form.parameters.reduce(into: [:])
        {
            $0[$1.key] = $1.value
        }

        switch type
        {
        case .build:
            guard
            let template:Unidoc.BuildTemplate = .init(parameters: form)
            else
            {
                return nil
            }

            self = .build(template)

        case .media:
            guard
            let prefix:String = form["\(Unidoc.PackageMediaSetting.media)"],
            let gif:String = form["\(Unidoc.PackageMediaSetting.media_gif)"],
            let jpg:String = form["\(Unidoc.PackageMediaSetting.media_jpg)"],
            let png:String = form["\(Unidoc.PackageMediaSetting.media_png)"],
            let svg:String = form["\(Unidoc.PackageMediaSetting.media_svg)"],
            let webp:String = form["\(Unidoc.PackageMediaSetting.media_webp)"]
            else
            {
                return nil
            }

            self = .media(.init(
                prefix: prefix.isEmpty ? nil : prefix,
                gif: gif.isEmpty ? nil : gif,
                jpg: jpg.isEmpty ? nil : jpg,
                png: png.isEmpty ? nil : png,
                svg: svg.isEmpty ? nil : svg,
                webp: webp.isEmpty ? nil : webp))
        }
    }
}
