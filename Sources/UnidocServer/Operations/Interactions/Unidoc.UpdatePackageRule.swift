extension Unidoc
{
    enum UpdatePackageRule:Sendable
    {
        case insertEditorFromGitHub(login:String)
        case insertEditor(Account)
        case revokeEditor(Account)
    }
}
extension Unidoc.UpdatePackageRule
{
    init?(from form:borrowing [String: String])
    {
        if  let login:String = form["login"]
        {
            self = .insertEditorFromGitHub(login: login)
        }
        else if
            let revoke:String = form["revoke"],
            let id:Unidoc.Account = .init(revoke)
        {
            self = .revokeEditor(id)
        }
        else
        {
            return nil
        }
    }
}
