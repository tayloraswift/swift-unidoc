import GitHubAPI
import HTML

extension GitHub.Repo.Owner:HyperTextOutputStreamable
{
    public static
    func += (dd:inout HTML.ContentEncoder, self:Self)
    {
        dd[.a]
        {
            $0.href = "https://github.com/\(self.login)"
            $0.target = "_blank"
        } = "@\(self.login)"
    }
}
