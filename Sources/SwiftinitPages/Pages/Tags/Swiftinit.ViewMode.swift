extension Swiftinit
{
    enum ViewMode:Comparable
    {
        case reader
        case owner
        case admin
    }
}
extension Swiftinit.ViewMode
{
    init(package _:Unidoc.PackageMetadata, user:Unidoc.User?)
    {
        guard
        let user:Unidoc.User = user
        else
        {
            self = .reader
            return
        }

        switch user.level
        {
        case .administratrix:   self = .admin
        case .machine:          self = .reader
        case .human:            self = .reader
        }
    }
}
