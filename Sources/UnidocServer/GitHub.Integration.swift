import GitHubAPI

extension GitHub
{
    public
    protocol Integration:AnyObject, Sendable
    {
        var agent:String { get }
        var oauth:OAuth { get }

        var pat:PersonalAccessToken { get }

        func iat(id installation:UInt) async throws -> InstallationAccessToken
    }
}
