extension Unidoc.UserConfigOperation
{
    enum Update
    {
        case generateKey
    }
}
extension Unidoc.UserConfigOperation.Update
{
    init?(from form:borrowing [String: String])
    {
        if  let generate:String = form["generate"],
            case "api-key" = generate
        {
            self = .generateKey
        }
        else
        {
            return nil
        }
    }
}
