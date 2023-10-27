import HTTPServer
import System

extension Server
{
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
            mode = .development(cache: .init(source: assets), port: options.port ?? 8443)
        }
        else
        {
            mode = .production

            switch options.port
            {
            case nil, 443?:
                break

            case let port?:
                Log[.warning] = "Ignoring custom port \(port) in production mode!"
            }
        }

        self.init(authority: authority,
            secrets: .init(
                github: options.github ? assets / "secrets" : nil),
            mode: mode)
    }
}
extension Server.Options
{
    var port:Int
    {
        switch self.mode
        {
        case .development(cache: _, port: let port):    port
        case .production:                               443
        }
    }
}
