import BSON
import HTML
import UnixTime

extension Swiftinit
{
    struct PackageBanner
    {
        private
        let repo:Unidoc.PackageRepo
        private
        let tag:String?

        init(repo:Unidoc.PackageRepo, tag:String? = nil)
        {
            self.repo = repo
            self.tag = tag
        }
    }
}
extension Swiftinit.PackageBanner:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.p] = self.repo.origin.about

        let pushed:BSON.Millisecond
        let icon:Swiftinit.SourceLink.Icon
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
            $0 += Swiftinit.SourceLink.init(
                target: self.tag.map { "\(self.repo.origin.https)/tree/\($0)" }
                    ?? self.repo.origin.https,
                icon: icon,
                file: path)

            $0[.span] = Swiftinit.PackageIndicators.init(
                pushed: pushed,
                stars: self.repo.stars)
        }
    }
}
