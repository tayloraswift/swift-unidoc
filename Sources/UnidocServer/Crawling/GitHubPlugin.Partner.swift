import Atomics
import GitHubClient
import GitHubAPI

extension GitHubPlugin
{
    @dynamicMemberLookup
    struct Partner
    {
        private
        let count:Counters

        let oauth:GitHubClient<GitHubOAuth>
        // let app:GitHubClient<GitHubApp>
        let api:GitHubClient<GitHubOAuth.API>

        init(count:Counters,
            oauth:GitHubClient<GitHubOAuth>,
            api:GitHubClient<GitHubOAuth.API>)
        {
            self.count = count
            self.oauth = oauth
            self.api = api
        }
    }
}
extension GitHubPlugin.Partner
{
    subscript<Int>(
        dynamicMember keyPath:KeyPath<GitHubPlugin.Counters, UnsafeAtomic<Int>>) -> Int
    {
        self.count[keyPath: keyPath].load(ordering: .relaxed)
    }
}
