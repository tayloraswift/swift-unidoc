extension GitHub.WebhookInstallationRepositories {
    @frozen public enum Delta: Equatable, Sendable {
        case additions([GitHub.RepoInvite])
        case deletions([GitHub.RepoInvite])
    }
}
