import GitHubAPI

extension GitHub.Repo
{
    @inlinable public
    var visibleInFeed:Bool
    {
        !self.topics.contains("swiftinit-invisible")
    }
}
