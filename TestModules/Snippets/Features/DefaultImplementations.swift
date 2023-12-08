public
protocol ProtocolA
{
    func f()
}

public
protocol ProtocolB:ProtocolA
{
}
extension ProtocolB
{
    public
    func f()
    {
    }
}

public
protocol ProtocolC:Identifiable
{
}
extension ProtocolC
{
    public
    var id:String { "" }
}

public
enum Enum
{
}
extension Enum:ProtocolB, ProtocolC
{
}
