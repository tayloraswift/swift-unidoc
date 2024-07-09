import MongoQL

extension Unidoc
{
    struct PackageByGitHubID
    {
        let id:Int32
    }
}
extension Unidoc.PackageByGitHubID:Mongo.PredicateEncodable
{
    func encode(to predicate:inout Mongo.PredicateEncoder)
    {
        predicate[Unidoc.PackageMetadata[.repo]
            / Unidoc.PackageRepo[.github]
            / Unidoc.GitHubOrigin[.id]] = self.id

        predicate[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.github]]
        {
            $0[.exists] = true
        }
    }
}
