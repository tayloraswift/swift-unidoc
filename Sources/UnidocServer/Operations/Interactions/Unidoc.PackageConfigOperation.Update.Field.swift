import BSON
import SymbolGraphs

extension Unidoc.PackageConfigOperation.Update
{
    enum Field
    {
        case platformPreference(Triple?)
        case media(Unidoc.PackageMedia?)
    }
}
extension Unidoc.PackageConfigOperation.Update.Field
{
    init?(from form:borrowing [String: String])
    {
        if  let triple:String = form["platform-preference"]
        {
            if  let triple:Triple = .init(triple)
            {
                self = .platformPreference(triple)
            }
            else if triple.isEmpty
            {
                self = .platformPreference(nil)
            }
            else
            {
                return nil
            }
        }
        else if
            let prefix:String = form["\(Unidoc.PackageMediaSetting.media)"],
            let gif:String = form["\(Unidoc.PackageMediaSetting.media_gif)"],
            let jpg:String = form["\(Unidoc.PackageMediaSetting.media_jpg)"],
            let png:String = form["\(Unidoc.PackageMediaSetting.media_png)"],
            let svg:String = form["\(Unidoc.PackageMediaSetting.media_svg)"],
            let webp:String = form["\(Unidoc.PackageMediaSetting.media_webp)"]
        {
            var media:Unidoc.PackageMedia = .init(prefix: prefix,
                gif: gif.isEmpty ? nil : gif,
                jpg: jpg.isEmpty ? nil : jpg,
                png: png.isEmpty ? nil : png,
                svg: svg.isEmpty ? nil : svg,
                webp: webp.isEmpty ? nil : webp)

            //  If the default prefix is empty, replace it with the first non-empty path.
            if  media.prefix.isEmpty,
                let first:String = media.gif ??
                    media.jpg ??
                    media.png ??
                    media.svg ??
                    media.webp
            {
                media.prefix = first
            }

            if  media.prefix.isEmpty
            {
                self = .media(nil)
            }
            else
            {
                self = .media(media)
            }
        }
        else
        {
            return nil
        }
    }
}
