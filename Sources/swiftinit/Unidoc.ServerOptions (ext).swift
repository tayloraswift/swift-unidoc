import GitHubAPI

extension Unidoc.ServerOptions
{
    var plugins:[any Unidoc.ServerPlugin]
    {
        var list:[any Unidoc.ServerPlugin] = []

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
            list.append(Unidoc.GraphLinkerPlugin.init(bucket: self.bucket.graphs))

            list.append(Swiftinit.AirdropPlugin.init())
            list.append(Swiftinit.LinterPlugin.init())
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
