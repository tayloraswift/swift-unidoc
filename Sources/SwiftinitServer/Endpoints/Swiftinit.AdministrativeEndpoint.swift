import HTTP
import MongoDB

extension Swiftinit
{
    protocol AdministrativeEndpoint:RestrictedEndpoint
    {
    }
}

extension Swiftinit.AdministrativeEndpoint
{
    func admit(level:Unidoc.User.Level) -> Bool
    {
        switch level
        {
        case .administratrix:   true
        case .machine:          false
        case .human:            false
        }
    }
}
