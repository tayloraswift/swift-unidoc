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
    mutating
    func crawled(repo:consuming Unidoc.PackageRepo)
    {
        //  Don’t wipe the fetched time.
        repo.fetched = self.repo?.fetched

        schedule:
        if  let interval:Milliseconds = repo.crawlingIntervalTarget(
                dormant: repo.dormant(by: .init(repo.crawled)),
                hidden: self.hidden,
                realm: self.realm)
        {
            var target:UnixMillisecond = repo.crawled.advanced(by: interval)

            //  If the repo is already scheduled to have its tags read, we should not keep
            //  postponing that.
            if  let expires:UnixMillisecond = self.repo?.expires,
                    expires < target
            {
                target = expires
            }

            //  We always need to set this because the blank repo instances lack it.
            repo.expires = target
        }
        else
        {
            repo.expires = nil
        }

        self.repo = repo
    }

    public mutating
    func fetched(repo:consuming Unidoc.PackageRepo)
    {
        repo.fetched = repo.crawled

        if  let interval:Milliseconds = repo.crawlingIntervalTarget(
                dormant: repo.dormant(by: .init(repo.crawled)),
                hidden: self.hidden,
                realm: self.realm)
        {
            repo.expires = repo.crawled.advanced(by: interval)
        }
        else
        {
            repo.expires = nil
        }

        self.repo = repo
    }
}
