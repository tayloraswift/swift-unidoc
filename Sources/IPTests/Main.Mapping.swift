import IP
import Testing

extension Main
{
    struct Mapping
    {
    }
}
extension Main.Mapping:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let v4:IP.V4 = tests.expect(value: .init("1.2.3.4"))
        {
            let v6:IP.V6 = .init(v4: v4)

            tests.expect(v6 ==? .init(0, 0, 0, 0, 0, 0xffff, 0x0102, 0x0304))
            tests.expect(v6.v4 ==? v4)
        }
    }
}
