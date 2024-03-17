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
        var mirror:Bool
        var bucket:AWS.S3.Bucket?
        var mode:Mode

        init(authority:any ServerAuthority,
            github:GitHub.Integration? = nil,
            mirror:Bool = false,
            bucket:AWS.S3.Bucket? = nil,
            mode:Mode = .production)
        {
            self.authority = authority
            self.github = github
            self.mirror = mirror
            self.bucket = bucket
            self.mode = mode
        }
    }
}
extension Swiftinit.ServerOptions
{
    private
    var development:Development?
    {
        switch self.mode
        {
        case .development(_, let options):  options
        case .production:                   nil
        }
    }
}
extension Swiftinit.ServerOptions
{
    subscript(dynamicMember keyPath:KeyPath<Development, Bool>) -> Bool
    {
        self.development?[keyPath: keyPath] ?? true
    }

    var replicaSet:String
    {
        self.development?.replicaSet ?? "swiftinit-rs"
    }

    var port:Int
    {
        self.development?.port ?? 443
    }
}
extension Swiftinit.ServerOptions
{
    var plugins:[any Swiftinit.ServerPlugin]
    {
        var list:[any Swiftinit.ServerPlugin] = []

        if  self.runPolicy
        {
            list.append(Swiftinit.PolicyPlugin.init())
        }

        if  self.mirror
        {
            return list
        }
        else
        {
            list.append(Swiftinit.LinkerPlugin.init(bucket: self.bucket))
        }

        guard
        let github:GitHub.Integration = self.github
        else
        {
            return list
        }

        if  self.runTelescope
        {
            list.append(GitHub.CrawlerPlugin<GitHub.RepoTelescope>.init(
                api: github.api,
                id: "telescope"))
        }
        if  self.runMonitor
        {
            list.append(GitHub.CrawlerPlugin<GitHub.RepoMonitor>.init(
                api: github.api,
                id: "monitor"))
        }

        return list
    }
}
