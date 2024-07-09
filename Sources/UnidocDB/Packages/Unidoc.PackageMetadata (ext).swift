import BSON
import MongoQL
import UnidocRecords
import UnixTime

extension Unidoc.PackageMetadata:Mongo.MasterCodingModel
{
}
extension Unidoc.PackageMetadata
{
    @inlinable public
    var rulers:Unidoc.PackageRulers { .init(editors: self.editors, owner: self.repo?.account) }
}
extension Unidoc.PackageMetadata
{
    public
    func nextTagsFetch() -> UnixMillisecond?
    {
        if  case _? = self.repoWebhook
        {
            return nil
        }

        guard
        let repo:Unidoc.PackageRepo = self.repo,
        let interval:Milliseconds = repo.crawlingIntervalTarget(
            dormant: repo.dormant(by: .init(repo.crawled)),
            hidden: self.hidden,
            realm: self.realm)
        else
        {
            return nil
        }

        return repo.crawled.advanced(by: interval)
    }
}
