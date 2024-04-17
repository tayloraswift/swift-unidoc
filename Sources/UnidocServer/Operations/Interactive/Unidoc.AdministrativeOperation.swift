import UnidocDB

extension Unidoc
{
    public
    protocol AdministrativeOperation:RestrictedOperation
    {
    }
}

extension Unidoc.AdministrativeOperation
{
    @inlinable public
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
