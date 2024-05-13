import GitHubAPI
import GitHubClient
import JSON

extension GitHub.Client<GitHub.PersonalAccessToken>.Connection
{
    public
    func inspect(ref:String, owner:String, repo:String) async throws -> GitHub.RefResponse
    {
        let query:JSON = .object
        {
            $0["query"] = """
            query
            {
                repository(owner: "\(owner)", name: "\(repo)")
                {
                    ref(qualifiedName: "\(ref)")
                    {
                        name, prefix, commit: target { sha: oid }
                    }
                }
            }
            """
        }

        let response:GraphQL.Response<GitHub.RefResponse> = try await self.post(
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

    public
    func crawl(owner:String, repo:String, tags:Int) async throws -> GitHub.RepoMonitorResponse
    {
        let query:JSON = .object
        {
            $0["query"] = """
            query
            {
                repository(owner: "\(owner)", name: "\(repo)")
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

                    refs(last: \(tags),
                        refPrefix: "refs/tags/",
                        orderBy: {field: TAG_COMMIT_DATE, direction: ASC})
                    {
                        nodes { name, commit: target { sha: oid } }
                    }
                }
            }
            """
        }

        let response:GraphQL.Response<GitHub.RepoMonitorResponse> = try await self.post(
            query: "\(query)")

        let error:GraphQL.ServerError? = response.errors.first { $0.type != "NOT_FOUND" }
        if  let error:GraphQL.ServerError
        {
            throw error
        }
        else
        {
            return response.data
        }
    }
}
