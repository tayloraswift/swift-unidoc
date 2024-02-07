extension Unidoc
{
    enum GroupTypeError:Error, Equatable, Sendable
    {
        case  conformer
        case `extension`
        case  intrinsic
        case  polygonal
        case  topic
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
        case .polygonal:    .polygonal
        case .topic:        .topic
        }
    }
}
