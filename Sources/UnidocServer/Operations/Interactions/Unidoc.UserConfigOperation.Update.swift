extension Unidoc.UserConfigOperation
{
    enum Update
    {
        case generateKey(for:Unidoc.Account)
    }
}
extension Unidoc.UserConfigOperation.Update
{
    init?(from form:borrowing [String: String])
    {
        if  let account:String = form["generate-api-key"],
            let account:Unidoc.Account = .init(account)
        {
            self = .generateKey(for: account)
        }
        else
        {
            return nil
        }
    }
}
