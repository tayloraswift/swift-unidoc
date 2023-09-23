import HTTP
import JSON
import Media
import UnidocDB
import UnidocQueries
import URI

extension PackageEditionsQuery.Output:ServerResponseFactory
{
    public
    func response(as type:AcceptType?) throws -> ServerResponse
    {
        switch type
        {
        case .application(.json):
            let json:JSON = .object
            {
                guard
                let repo:PackageRepo = self.record.repo,
                let release:PackageEditionsQuery.Facet = self.releases.first
                else
                {
                    return
                }

                $0["repo"] = "https://\(repo.origin)"

                $0["release"]
                {
                    $0["graphs"] = release.graphs?.count ?? 0
                    $0["tag"] = release.edition.name
                }

                guard
                let prerelease:PackageEditionsQuery.Facet = self.prereleases.first,
                    prerelease.edition.patch > release.edition.patch
                else
                {
                    return
                }

                $0["prerelease"]
                {
                    $0["graphs"] = prerelease.graphs?.count ?? 0
                    $0["tag"] = prerelease.edition.name
                }
            }

            return .ok(.init(
                content: .binary(json.utf8),
                type: .application(.json, charset: .utf8)))

        case _:
            let list:Site.Tags.List = .init(from: self)
            return .ok(list.resource())
        }
    }
}
