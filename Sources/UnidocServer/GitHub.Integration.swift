import GitHubAPI

extension GitHub
{
    public
    protocol Integration:Unidoc.Registrar
    {
        var agent:String { get }
        var oauth:OAuth { get }
        var pat:PersonalAccessToken { get }
    }
}
