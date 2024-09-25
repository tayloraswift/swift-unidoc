import ISO

extension Unidoc
{
    enum ClientPrivilege:Sendable
    {
        case majorSearchEngine(Searchbot, verified:Bool)
        case barbie(ISO.Locale, verified:Bool)
    }
}
