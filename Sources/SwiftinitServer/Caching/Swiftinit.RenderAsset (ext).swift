import SwiftinitAssets

extension Swiftinit.Asset:CacheKey
{
    /// Indicates if the asset will be reloaded from disk when hot-reloading is enabled.
    /// (Some assets will never be reloaded, such as the favicon.)
    var reloadable:Bool
    {
        switch self
        {
        case    .admin_css,
                .admin_css_map,
                .main_css,
                .main_css_map,
                .main_js,
                .main_js_map:
            return true

        case    _:
            return false
        }
    }
}
