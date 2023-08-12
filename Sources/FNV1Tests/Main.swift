import FNV1
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "USR"
        {
            let usr:String = "s:11SwiftSyntax04DeclB0VyACxcAA0cB8ProtocolRzlufc"

            let fnv24:FNV24 = .init(hashing: usr)

            tests.expect("\(fnv24)" ==? "5X90C")

            let full:FNV24.Extended = .init(hashing: usr)

            tests.expect(fnv24.min.rawValue <=? full.rawValue)
            tests.expect(fnv24.max.rawValue >=? full.rawValue)

            let fnv32:FNV32 = .init(hashing: usr)

            tests.expect(fnv32 ==? .recover(from: full))
        }
    }
}
