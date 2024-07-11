extension Unidoc
{
    enum WebhookError:Error
    {
        case missingEventType
        case missingHookID
        case invalidHookID
        case unverifiedOrigin
    }
}
extension Unidoc.WebhookError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .missingEventType:      return "Missing event type"
        case .missingHookID:         return "Missing hook ID"
        case .invalidHookID:         return "Invalid hook ID"
        case .unverifiedOrigin:      return "Unverified IP address"
        }
    }
}
