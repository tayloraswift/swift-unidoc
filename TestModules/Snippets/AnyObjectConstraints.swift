public
enum Enum<T>
{
}

extension Enum where T:AnyObject
{
    var member:Void { return }
}
extension Enum where T:Sendable
{
    var other:Void { return }
}
