import GitHubIntegration
import HTTPServer
import MongoDB
import UnidocDatabase

struct LoginOperation:Sendable
{
    let state:String
    let code:String

    init(state:String, code:String)
    {
        self.state = state
        self.code = code
    }
}
extension LoginOperation
{
    init?(parameters:__shared [(key:String, value:String)])
    {
        var state:String?
        var code:String?

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "state":   state = value
            case "code":    code = value
            case _:         continue
            }
        }

        if  let state:String,
            let code:String
        {
            self.init(state: state, code: code)
        }
        else
        {
            return nil
        }
    }
}
extension LoginOperation:GitHubOperation
{
    func load(from github:GitHubApplication.Client,
        into _:Unidoc.Database,
        pool _:Mongo.SessionPool,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
    {
        let message:String
        if  case self.state? = cookies.login
        {
            switch await github.exchange(code: self.code)
            {
            case .success(let tokens):
                return .resource(.init(.one(canonical: nil),
                    content: .string("\(tokens)"),
                    type: .text(.plain, charset: .utf8)))

            case .failure(.fetch(let error)):
                message = "Failed to fetch auth tokens from github.com (\(error))"

            case .failure(.status), .failure(.response):
                message = "Authorization failed"
            }
        }
        else
        {
            message = "Authorization failed: state mismatch"
        }

        return .resource(.init(.one(canonical: nil),
            content: .string(message),
            type: .text(.plain, charset: .utf8)))
    }
}
