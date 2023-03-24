protocol _Underscored
{
    var requirement:Void { get }
}
extension _Underscored
{
    var member:Void { return }
}

struct Struct:_Underscored
{
    var requirement:Void { return }
}
