import ISO

extension Unidoc.PackageRepoDescriptionList
{
    enum DisplayMode
    {
        case abridged
        case expanded(ISO.Locale)
    }
}
