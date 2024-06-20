extension Unidoc
{
    enum GroupTypeError:Error, Equatable, Sendable
    {
        case  conformer
        case `extension`
        case  intrinsic
        case  curator
    }
}
extension Unidoc.GroupTypeError
{
    static
    func reject(_ group:Unidoc.AnyGroup) -> Self
    {
        switch group
        {
        case .conformer:    .conformer
        case .extension:    .extension
        case .intrinsic:    .intrinsic
        case .curator:      .curator
        }
    }
}
