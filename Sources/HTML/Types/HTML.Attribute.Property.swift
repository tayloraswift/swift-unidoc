extension HTML.Attribute
{
    /// See https://ogp.me/
    @frozen public
    enum Property:String, Equatable, Hashable, Sendable
    {
        case og_audio = "og:audio"
        case og_audio_type = "og:audio:type"

        case og_image = "og:image"
        case og_image_alt = "og:image:alt"
        case og_image_type = "og:image:type"
        case og_image_width = "og:image:width"
        case og_image_height = "og:image:height"

        case og_video = "og:video"
        case og_video_type = "og:video:type"
        case og_video_width = "og:video:width"
        case og_video_height = "og:video:height"

        case og_description = "og:description"
        case og_determiner = "og:determiner"
        case og_locale = "og:locale"
        case og_locale_alternate = "og:locale:alternate"
        case og_site_name = "og:site_name"
        case og_title = "og:title"
        case og_type = "og:type"
        case og_url = "og:url"
    }
}
