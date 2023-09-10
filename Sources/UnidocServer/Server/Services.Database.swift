import MongoDB
import UnidocDB

extension Services
{
    struct Database:Sendable
    {
        let sessions:Mongo.SessionPool

        let account:AccountDatabase
        let package:PackageDatabase
        let unidoc:UnidocDatabase

        init(sessions:Mongo.SessionPool,
            account:AccountDatabase,
            package:PackageDatabase,
            unidoc:UnidocDatabase)
        {
            self.sessions = sessions

            self.account = account
            self.package = package
            self.unidoc = unidoc
        }
    }
}
