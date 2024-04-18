import BSON
import HTML
import UnixTime

extension Unidoc
{
    struct PackageBanner
    {
        private
        let repo:Unidoc.PackageRepo
        private
        let tag:String?
        private
        let now:UnixInstant

        init(repo:Unidoc.PackageRepo, tag:String? = nil, now:UnixInstant)
        {
            self.repo = repo
            self.tag = tag
            self.now = now
        }
    }
}
extension Unidoc.PackageBanner:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.p] = self.repo.origin.about

        let pushed:BSON.Millisecond
        let icon:Unidoc.SourceLink.Icon
        let path:Substring

        switch self.repo.origin
        {
        case .github(let origin):
            pushed = origin.pushed
            icon = .github
            path = "\(origin.owner)/\(origin.name)"
        }

        html[.p, { $0.class = "chyron" }]
        {
            $0 += Unidoc.SourceLink.init(
                target: self.tag.map { "\(self.repo.origin.https)/tree/\($0)" }
                    ?? self.repo.origin.https,
                icon: icon,
                file: path)

            $0[.span] = Unidoc.PackageIndicators.init(
                pushed: pushed,
                stars: self.repo.stars,
                now: self.now)
        }
    }
}
