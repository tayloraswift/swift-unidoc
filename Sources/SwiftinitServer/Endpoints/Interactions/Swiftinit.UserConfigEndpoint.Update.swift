extension Swiftinit.UserConfigEndpoint
{
    enum Update
    {
        case generateKey
    }
}
extension Swiftinit.UserConfigEndpoint.Update
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
