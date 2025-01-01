import FNV1
import Testing

@Suite
struct FNV
{
    @Test
    static func USR()
    {
        let usr:String = "s:11SwiftSyntax04DeclB0VyACxcAA0cB8ProtocolRzlufc"

        let fnv24:FNV24 = .init(hashing: usr)

        #expect("\(fnv24)" == "5X90C")

        let full:FNV24.Extended = .init(hashing: usr)

        #expect(fnv24.min.rawValue <= full.rawValue)
        #expect(fnv24.max.rawValue >= full.rawValue)

        let fnv32:FNV32 = .init(hashing: usr)

        #expect(fnv32 == .recover(from: full))
    }
}
