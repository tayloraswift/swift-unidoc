import GitHubAPI
import HTML

extension GitHub.RepoTelescope
{
    enum Event:Sendable
    {
        case discovery(Discovery)
    }
}
extension GitHub.RepoTelescope.Event:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .discovery(let self):
            div[.h3] = "Discovered package"
            div[.dl] = self
        }
    }
}
