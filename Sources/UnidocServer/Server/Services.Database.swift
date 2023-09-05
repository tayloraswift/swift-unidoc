import MongoDB
import UnidocDatabase

extension Services
{
    struct Database
    {
        let sessions:Mongo.SessionPool

        let accounts:Account.Database
        let unidoc:Unidoc.Database

        init(sessions:Mongo.SessionPool,
            accounts:Account.Database,
            unidoc:Unidoc.Database)
        {
            self.sessions = sessions

            self.accounts = accounts
            self.unidoc = unidoc
        }
    }
}
