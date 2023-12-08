import MongoDB
import UnidocDB

extension Swiftinit
{
    struct DB:Sendable
    {
        let sessions:Mongo.SessionPool

        let account:AccountDatabase
        let unidoc:UnidocDatabase

        init(sessions:Mongo.SessionPool,
            account:AccountDatabase,
            unidoc:UnidocDatabase)
        {
            self.sessions = sessions

            self.account = account
            self.unidoc = unidoc
        }
    }
}
