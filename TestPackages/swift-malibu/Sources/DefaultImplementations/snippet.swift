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
enum Enum
{
}
extension Enum:ProtocolB
{
}
