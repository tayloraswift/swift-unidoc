import BSON
import HTML
import UnixTime

extension Swiftinit
{
    struct PackageCard
    {
        private
        let package:Unidoc.PackageOutput
        private
        let now:UnixInstant

        /// Cached for sort performance.
        let order:String

        init(_ package:Unidoc.PackageOutput, now:UnixInstant)
        {
            self.package = package
            self.now = now

            let name:String = package.metadata.repo?.origin.name
                ?? package.metadata.symbol.identifier
            self.order = name.lowercased()
        }
    }
}
extension Swiftinit.PackageCard
{
    var owner:String? { self.package.metadata.repo?.origin.owner }
    var stars:Int? { self.package.metadata.repo?.stars }
    var name:String
    {
        self.package.metadata.repo?.origin.name ?? self.package.metadata.symbol.identifier
    }
}
extension Swiftinit.PackageCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        let dead:Bool = self.package.metadata.repo?.origin.alive == false

        li[.p]
        {
            $0[.span]
            {
                $0[.a]
                {
                    $0.href = "\(Swiftinit.Tags[self.package.metadata.symbol])"
                    $0.class = dead ? "dead" : nil

                } = self.name

                $0[.span] { $0.class = "owner" } = self.package.metadata.repo?.origin.owner
            }

            if  let repo:Unidoc.PackageRepo = self.package.metadata.repo
            {
                $0[.span] { $0.class = "license" } = repo.license?.name ?? "Unknown License"
            }
            else
            {
                $0[.span] { $0.class = "placeholder" } = "Local"
            }
        }

        li[.p] = self.package.metadata.repo?.origin.about

        li[.p, { $0.class = "chyron" }]
        {
            if  dead
            {
                $0[.span] { $0.class = "placeholder" } = "Archived!"
            }
            else if
                let release:Unidoc.EditionMetadata = self.package.release
            {
                $0[.span] { $0.class = "release" } = "\(release.patch)"
            }
            else
            {
                $0[.span] { $0.class = "placeholder" } = "No releases"
            }

            guard
            let repo:Unidoc.PackageRepo = self.package.metadata.repo
            else
            {
                return
            }

            let pushed:BSON.Millisecond
            switch repo.origin
            {
            case .github(let origin):   pushed = origin.pushed
            }

            $0[.span] = Swiftinit.PackageIndicators.init(
                pushed: pushed,
                stars: repo.stars,
                now: self.now)
        }
    }
}
