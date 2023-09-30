import UnidocPages

extension Server
{
    struct Agent:Sendable
    {
        let id:String

        init(id:String)
        {
            self.id = id
        }
    }
}
extension Server.Agent
{
    init?(_ lines:[String])
    {
        guard
        let line:String = lines.first
        else
        {
            return nil
        }

        self.init(id: line)
    }

    var statisticalCategory:WritableKeyPath<ServerTour.Stats.ByAgent, Int>
    {
        func isLikelyMajorSearchEngine(agent:String) -> Bool
        {
            return agent.contains("bing")
                || agent.contains("slurp")
                || agent.contains("yandex")
                || agent.contains("baidu")
        }
        func isLikelyMinorSearchEngine(agent:String) -> Bool
        {
            return agent.contains("duckduckgo")
                || agent.contains("naver")
                || agent.contains("petal")
                || agent.contains("quant")
                || agent.contains("seekport")
                || agent.contains("seznam")
        }
        func isLikelyRobot(agent:String) -> Bool
        {
            return agent.contains("bot")
                || agent.contains("crawler")
                || agent.contains("spider")
        }
        func isLikelyBrowser(agent:String) -> Bool
        {
            return agent.contains("mozilla")
        }

        let agent:String = self.id.lowercased()

        if  agent.contains("google")
        {
            return \.likelyGooglebot
        }
        else if isLikelyMajorSearchEngine(agent: agent)
        {
            return \.likelyMajorSearchEngine
        }
        else if isLikelyMinorSearchEngine(agent: agent)
        {
            return \.likelyMinorSearchEngine
        }
        else if isLikelyRobot(agent: agent)
        {
            return \.likelyBot
        }
        else if isLikelyBrowser(agent: agent)
        {
            return \.likelyBrowser
        }
        else
        {
            return \.likelyTool
        }
    }
}
