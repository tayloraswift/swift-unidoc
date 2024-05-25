extension Unidoc
{
    enum PackageWebhookError:Error
    {
        case missingEventType
        case unverifiedOrigin
    }
}
extension Unidoc.PackageWebhookError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .missingEventType:      return "Missing event type"
        case .unverifiedOrigin:      return "Unverified IP address"
        }
    }
}
