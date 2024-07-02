import GitHubAPI

extension GitHub
{
    public
    protocol Integration:AnyObject, Sendable
    {
        var agent:String { get }
        var oauth:OAuth { get }

        var pat:PersonalAccessToken { get }
    }
}
