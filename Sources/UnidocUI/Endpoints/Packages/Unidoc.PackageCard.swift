import BSON
import HTML
import SemanticVersions
import UnixTime

extension Unidoc
{
    struct PackageCard
    {
        private
        let metadata:Unidoc.EditionOutput
        private
        let now:UnixInstant

        /// Cached for sort performance.
        let order:String

        init(_ metadata:Unidoc.EditionOutput, now:UnixInstant)
        {
            self.metadata = metadata
            self.now = now

            let name:String = metadata.package.repo?.origin.name
                ?? metadata.package.symbol.identifier
            self.order = name.lowercased()
        }
    }
}
extension Unidoc.PackageCard
{
    var owner:String? { self.metadata.package.repo?.origin.owner }
    var stars:Int? { self.metadata.package.repo?.stars }
    var name:String
    {
        self.metadata.package.repo?.origin.name ?? self.metadata.package.symbol.identifier
    }
}
extension Unidoc.PackageCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        let dead:Bool = self.metadata.package.repo?.origin.alive == false

        li[.p]
        {
            $0[.span]
            {
                $0[.a]
                {
                    $0.href = "\(Unidoc.TagsEndpoint[self.metadata.package.symbol])"
                    $0.class = dead ? "dead" : nil

                } = self.name

                $0[.span] { $0.class = "owner" } = self.metadata.package.repo?.origin.owner
            }

            if  let repo:Unidoc.PackageRepo = self.metadata.package.repo
            {
                $0[.span] { $0.class = "license" } = repo.license?.name ?? "Unknown License"
            }
            else
            {
                $0[.span] { $0.class = "placeholder" } = "Local"
            }
        }

        li[.p] = self.metadata.package.repo?.origin.about

        li[.p, { $0.class = "chyron" }]
        {
            if  dead
            {
                $0[.span] { $0.class = "placeholder" } = "Archived!"
            }
            else if
                let patch:PatchVersion = self.metadata.edition?.semver
            {
                $0[.span] { $0.class = "release" } = "\(patch)"
            }
            else
            {
                $0[.span] { $0.class = "placeholder" } = "No releases"
            }

            guard
            let repo:Unidoc.PackageRepo = self.metadata.package.repo
            else
            {
                return
            }

            let pushed:BSON.Millisecond
            switch repo.origin
            {
            case .github(let origin):   pushed = origin.pushed
            }

            $0[.span] = Unidoc.PackageIndicators.init(
                pushed: pushed,
                stars: repo.stars,
                now: self.now)
        }
    }
}
