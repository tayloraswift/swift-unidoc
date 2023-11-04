import HTTPServer
import System

extension Server
{
    @dynamicMemberLookup
    struct Options
    {
        let authority:any ServerAuthority
        let secrets:Secrets
        let mode:Mode

        init(authority:any ServerAuthority, secrets:Secrets, mode:Mode)
        {
            self.authority = authority
            self.secrets = secrets
            self.mode = mode
        }
    }
}
extension Server.Options
{
    init(from options:Main.Options) throws
    {
        let authority:any ServerAuthority = try options.authority.load(
            certificates: options.certificates)

        let assets:FilePath = "Assets"
        let mode:Mode

        if  authority is Localhost
        {
            mode = .development(.init(source: assets), options.development)
        }
        else
        {
            mode = .production
        }

        self.init(authority: authority,
            secrets: .init(
                github: options.github ? assets / "secrets" : nil),
            mode: mode)
    }
}
extension Server.Options
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
