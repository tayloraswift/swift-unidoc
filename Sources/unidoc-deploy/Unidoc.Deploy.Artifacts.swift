extension Unidoc.Deploy
{
    enum Artifacts
    {
        case builder
        case server(matching:String?)
        case assets(matching:String?)
    }
}
