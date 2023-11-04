import Testing
import IP

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "Parsing" / "V6"
        {
            if  let tests:TestGroup = tests / "Zero",
                let value:IP.V6 = tests.expect(
                    value: .init("::"))
            {
                tests.expect(value ==? .zero)
            }

            if  let tests:TestGroup = tests / "Ones",
                let value:IP.V6 = tests.expect(
                    value: .init("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"))
            {
                tests.expect(value ==? .ones)
            }

            if  let tests:TestGroup = tests / "Prefix16",
                let value:IP.V6 = tests.expect(
                    value: .init("abcd::"))
            {
                tests.expect(value ==? .init(0xabcd, 0, 0, 0, 0, 0, 0, 0))
            }
            if  let tests:TestGroup = tests / "Prefix32",
                let value:IP.V6 = tests.expect(
                    value: .init("abcd:1234::"))
            {
                tests.expect(value ==? .init(0xabcd, 0x1234, 0, 0, 0, 0, 0, 0))
            }

            if  let tests:TestGroup = tests / "Prefix32Suffix16",
                let value:IP.V6 = tests.expect(
                    value: .init("abcd:1234::cdef"))
            {
                tests.expect(value ==? .init(0xabcd, 0x1234, 0, 0, 0, 0, 0, 0xcdef))
            }
            if  let tests:TestGroup = tests / "Prefix32Suffix32",
                let value:IP.V6 = tests.expect(
                    value: .init("abcd:1234::5678:cdef"))
            {
                tests.expect(value ==? .init(0xabcd, 0x1234, 0, 0, 0, 0, 0x5678, 0xcdef))
            }
            if  let tests:TestGroup = tests / "Prefix16Suffix32",
                let value:IP.V6 = tests.expect(
                    value: .init("abcd::5678:cdef"))
            {
                tests.expect(value ==? .init(0xabcd, 0, 0, 0, 0, 0, 0x5678, 0xcdef))
            }

            if  let tests:TestGroup = tests / "Suffix32",
                let value:IP.V6 = tests.expect(
                    value: .init("::5678:cdef"))
            {
                tests.expect(value ==? .init(0, 0, 0, 0, 0, 0, 0x5678, 0xcdef))
            }
            if  let tests:TestGroup = tests / "Suffix16",
                let value:IP.V6 = tests.expect(
                    value: .init("::cdef"))
            {
                tests.expect(value ==? .init(0, 0, 0, 0, 0, 0, 0, 0xcdef))
            }

            if  let tests:TestGroup = tests / "Roundtripping",
                let value:IP.V6 = tests.expect(
                    value: .init("0123:2345:3456:4567:5678:6789:789a:89ab")),
                let again:IP.V6 = tests.expect(
                    value: .init("\(value)"))
            {
                tests.expect(value ==? again)

                tests.expect(UInt64.init(bigEndian: value.prefix) ==? 0x0123_2345_3456_4567)
                tests.expect(UInt64.init(bigEndian: value.subnet) ==? 0x5678_6789_789a_89ab)

                tests.expect(value ==? .init(
                    0x0123,
                    0x2345,
                    0x3456,
                    0x4567,
                    0x5678,
                    0x6789,
                    0x789a,
                    0x89ab))
            }
        }

        if  let tests:TestGroup = tests / "Mapping",
            let v4:IP.V4 = tests.expect(value: .init("1.2.3.4"))
        {
            let v6:IP.V6 = .init(v4: v4)

            tests.expect(v6 ==? .init(0, 0, 0, 0, 0, 0xffff, 0x0102, 0x0304))
        }

        if  let tests:TestGroup = tests / "Masking"
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
}
