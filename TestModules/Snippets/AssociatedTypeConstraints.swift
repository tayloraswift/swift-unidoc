public
protocol Protocol
{
}
extension Protocol where Self:RawRepresentable, RawValue:Protocol
{
    public
    func f() { }
}
