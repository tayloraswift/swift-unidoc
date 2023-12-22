import GitHubAPI
import GitHubClient
import JSON

extension GitHubClient<GitHub.API>.Connection
{
    func inspect(tag:String,
        owner:String,
        repo:String,
        pat:String) async throws -> GitHubPlugin.TagResponse
    {
        let query:JSON = .object
        {
            $0["query"] = """
            query
            {
                repository(owner: "\(owner)", name: "\(repo)")
                {
                    ref(qualifiedName: "\(tag)")
                    {
                        name, commit: target { sha: oid }
                    }
                }
            }
            """
        }
        return try await self.post(query: "\(query)", with: pat)
    }

    func crawl(
        owner:String,
        repo:String,
        pat:String) async throws -> GitHubPlugin.RepoMonitorResponse
    {
        let query:JSON = .object
        {
            $0["query"] = """
            query
            {
                repository(owner: "\(owner)", name: "\(repo)")
                {
                    id: databaseId
                    owner { login }
                    name

                    license: licenseInfo { id: spdxId, name }
                    topics: repositoryTopics(first: 16)
                    {
                        nodes { topic { name } }
                    }
                    master: defaultBranchRef { name }

                    watchers(first: 0) { count: totalCount }
                    forks: forkCount
                    stars: stargazerCount
                    size: diskUsage

                    archived: isArchived
                    disabled: isDisabled
                    fork: isFork

                    homepage: homepageUrl
                    about: description

                    created: createdAt
                    updated: updatedAt
                    pushed: pushedAt

                    refs(last: 10,
                        refPrefix: "refs/tags/",
                        orderBy: {field: TAG_COMMIT_DATE, direction: ASC})
                    {
                        nodes { name, commit: target { sha: oid } }
                    }
                }
            }
            """
        }
        return try await self.post(query: "\(query)", with: pat)
    }

    func search(repos search:String,
        limit:Int = 100,
        pat:String) async throws -> GitHubPlugin.RepoTelescopeResponse
    {
        let query:JSON = .object
        {
            $0["query"] = """
            query
            {
                search(query: "\(search)", type: REPOSITORY, first: \(limit))
                {
                    nodes
                    {
                        ... on Repository
                        {
                            id: databaseId
                            owner { login }
                            name

                            license: licenseInfo { id: spdxId, name }
                            topics: repositoryTopics(first: 16)
                            {
                                nodes { topic { name } }
                            }
                            master: defaultBranchRef { name }

                            watchers(first: 0) { count: totalCount }
                            forks: forkCount
                            stars: stargazerCount
                            size: diskUsage

                            archived: isArchived
                            disabled: isDisabled
                            fork: isFork

                            homepage: homepageUrl
                            about: description

                            created: createdAt
                            updated: updatedAt
                            pushed: pushedAt
                        }
                    }
                }
            }
            """
        }

        return try await self.post(query: "\(query)", with: pat)
    }
}
