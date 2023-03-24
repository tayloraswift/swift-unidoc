public
protocol _Underscored
{
    var requirement:Void { get }
}
extension _Underscored
{
    public
    var member:Void { return }
}

public
struct Struct:_Underscored
{
    public
    var requirement:Void { return }
}
