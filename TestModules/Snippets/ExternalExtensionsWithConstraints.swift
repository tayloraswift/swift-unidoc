import ExtendableTypesWithConstraints

extension Protocol where T:Equatable
{
    public
    func external(_:T) where T:Sendable
    {
    }
}
extension Struct where T:Equatable
{
    public
    func external(_:T) where T:Sendable
    {
    }
}
