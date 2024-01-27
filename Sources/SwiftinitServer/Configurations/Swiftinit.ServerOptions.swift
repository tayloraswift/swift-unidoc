import GitHubAPI
import HTTPServer
import S3

extension Swiftinit
{
    @dynamicMemberLookup
    struct ServerOptions:Sendable
    {
        let authority:any ServerAuthority
        var github:GitHub.Integration?
        var bucket:AWS.S3.Bucket?
        var mode:Mode

        init(authority:any ServerAuthority,
            github:GitHub.Integration? = nil,
            bucket:AWS.S3.Bucket? = nil,
            mode:Mode = .production)
        {
            self.authority = authority
            self.github = github
            self.bucket = bucket
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
