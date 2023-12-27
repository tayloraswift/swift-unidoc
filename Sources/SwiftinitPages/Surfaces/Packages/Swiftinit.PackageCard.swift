import HTML
import UnixTime

extension Swiftinit
{
    struct PackageCard
    {
        private
        let package:Unidoc.PackageOutput

        init(_ package:Unidoc.PackageOutput)
        {
            self.package = package
        }
    }
}
extension Swiftinit.PackageCard:HyperTextOutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.p]
        {
            $0[.span]
            {
                $0[.a]
                {
                    $0.href = "\(Swiftinit.Tags[self.package.metadata.symbol])"
                } = self.package.metadata.repo?.origin.name ??
                    self.package.metadata.symbol.identifier

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
            if  let release:Unidoc.EditionMetadata = self.package.release
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

            $0[.span]
            {
                switch repo.origin
                {
                case .github(let origin):
                    let age:Age = .init(.now() - .millisecond(origin.pushed.value))
                    $0[.span]
                    {
                        $0.class = "pushed"
                        $0.title = """
                        This package’s repository was last pushed to \(age.long).
                        """
                    } = age.short
                }

                $0[.span]
                {
                    $0.class = "stars"
                    $0.title = """
                    This package’s repository has
                    \(repo.stars) \(repo.stars != 1 ? "stars" : "star").
                    """
                } = "\(repo.stars)"
            }
        }
    }
}
