import MongoDB
import UnidocDatabase

extension Services
{
    struct Database
    {
        let sessions:Mongo.SessionPool

        let accounts:AccountDatabase
        let packages:PackageDatabase
        let unidoc:UnidocDatabase

        init(sessions:Mongo.SessionPool,
            accounts:AccountDatabase,
            packages:PackageDatabase,
            unidoc:UnidocDatabase)
        {
            self.sessions = sessions

            self.accounts = accounts
            self.packages = packages
            self.unidoc = unidoc
        }
    }
}
