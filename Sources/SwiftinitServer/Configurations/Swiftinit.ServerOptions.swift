import GitHubAPI
import HTTPServer

extension Swiftinit
{
    @dynamicMemberLookup
    struct ServerOptions:Sendable
    {
        let authority:any ServerAuthority
        var github:GitHub.Integration?
        var mode:Mode

        init(authority:any ServerAuthority,
            github:GitHub.Integration? = nil,
            mode:Mode = .production)
        {
            self.authority = authority
            self.github = github
            self.mode = mode
        }
    }
}
extension Swiftinit.ServerOptions
{
    subscript(dynamicMember keyPath:KeyPath<Development, Bool>) -> Bool
    {
        switch self.mode
        {
        case .development(_, let options):  options[keyPath: keyPath]
        case .production:                   true
        }
    }

    var port:Int
    {
        switch self.mode
        {
        case .development(_, let options):  options.port
        case .production:                   443
        }
    }
}
