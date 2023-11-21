extension ServerProfile.ByStatus
{
    @frozen public
    enum SectorKey
    {
        case ok
        case notModified
        case multipleChoices
        case redirectedPermanently
        case redirectedTemporarily
        case notFound
        case gone
        case errored
        case unauthorized
    }
}
extension ServerProfile.ByStatus.SectorKey:Identifiable
{
    @inlinable public
    var id:String
    {
        switch self
        {
        case .ok:                       "ok"
        case .notModified:              "not-modified"
        case .multipleChoices:          "multiple-choices"
        case .redirectedPermanently:    "redirected-permanently"
        case .redirectedTemporarily:    "redirected-temporarily"
        case .notFound:                 "not-found"
        case .gone:                     "gone"
        case .errored:                  "errored"
        case .unauthorized:             "unauthorized"
        }
    }
}
extension ServerProfile.ByStatus.SectorKey:PieSectorKey
{
    @inlinable public
    var name:String
    {
        switch self
        {
        case .ok:                       "OK"
        case .notModified:              "Not Modified"
        case .multipleChoices:          "Multiple Choices"
        case .redirectedPermanently:    "Redirected Permanently"
        case .redirectedTemporarily:    "Redirected Temporarily"
        case .notFound:                 "Not Found"
        case .gone:                     "Gone"
        case .errored:                  "Errored"
        case .unauthorized:             "Unauthorized"
        }
    }
}
