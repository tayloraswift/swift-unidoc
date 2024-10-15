import IP
import Testing_

extension Main
{
    struct ParsingV4
    {
    }
}
extension Main.ParsingV4:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Localhost",
            let value:IP.V4 = tests.expect(
                value: .init("127.0.0.1"))
        {
            tests.expect(value ==? .localhost)
        }
    }
}
