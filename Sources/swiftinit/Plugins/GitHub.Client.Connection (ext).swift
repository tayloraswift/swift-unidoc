import GitHubAPI
import GitHubClient
import JSON

extension GitHub.Client<GitHub.API<String>>.Connection
{
    func search(repos search:String,
        limit:Int = 100) async throws -> GitHub.RepoTelescopeResponse
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
                            owner
                            {
                                login
                                ... on User { id: databaseId }
                                ... on Organization { id: databaseId }
                            }
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

        let response:GraphQL.Response<GitHub.RepoTelescopeResponse> = try await self.post(
            query: "\(query)")

        if  let error:GraphQL.ServerError = response.errors.first
        {
            throw error
        }
        else
        {
            return response.data
        }
    }
}
