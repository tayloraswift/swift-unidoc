import Testing
import IP

extension Main
{
    struct MaskingV6
    {
    }
}
extension Main.MaskingV6:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let value:IP.V6 = .init(
            0x0123,
            0x2345,
            0x3456,
            0x4567,
            0x5678,
            0x6789,
            0x789a,
            0x89ab)

        tests.expect(value / 0 ==? .zero)
        tests.expect(value / 1 ==? .init(0x0000, 0, 0, 0, 0, 0, 0, 0))
        tests.expect(value / 8 ==? .init(0x0100, 0, 0, 0, 0, 0, 0, 0))
        tests.expect(value / 16 ==? .init(0x0123, 0, 0, 0, 0, 0, 0, 0))
        tests.expect(value / 32 ==? .init(0x0123, 0x2345, 0, 0, 0, 0, 0, 0))
        tests.expect(value / 60 ==? .init(0x0123, 0x2345, 0x3456, 0x4560, 0, 0, 0, 0))
        tests.expect(value / 64 ==? .init(0x0123, 0x2345, 0x3456, 0x4567, 0, 0, 0, 0))
        tests.expect(value / 68 ==? .init(0x0123, 0x2345, 0x3456, 0x4567, 0x5000, 0, 0, 0))
        tests.expect(value / 96 ==? .init(
            0x0123,
            0x2345,
            0x3456,
            0x4567,
            0x5678,
            0x6789,
            0,
            0))
        tests.expect(value / 112 ==? .init(
            0x0123,
            0x2345,
            0x3456,
            0x4567,
            0x5678,
            0x6789,
            0x789a,
            0))
        tests.expect(value / 120 ==? .init(
            0x0123,
            0x2345,
            0x3456,
            0x4567,
            0x5678,
            0x6789,
            0x789a,
            0x8900))
        tests.expect(value / 127 ==? .init(
            0x0123,
            0x2345,
            0x3456,
            0x4567,
            0x5678,
            0x6789,
            0x789a,
            0x89aa))
        tests.expect(value / 128 ==? value)
    }
}
