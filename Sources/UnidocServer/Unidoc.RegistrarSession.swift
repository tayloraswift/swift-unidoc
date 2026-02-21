import GitHubAPI

extension Unidoc {
    public protocol RegistrarSession {
        func lookup(owner: String, repo: String, ref: String) async throws -> GitHub.Ref?
        func lookup(owner: String, repo: String) async throws -> GitHub.Repo?
    }
}
