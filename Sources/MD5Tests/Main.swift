import MD5
import Testing

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Strings"
        {
            let string:String   =   "d41d8cd98f00b204e9800998ecf8427e"
            let hash:MD5        =  0xd41d8cd98f00b204e9800998ecf8427e

            if  let tests:TestGroup = tests / "Parsing",
                let parsed:MD5 = tests.expect(value: .init(string))
            {
                tests.expect(parsed ==? hash)
            }
            if  let tests:TestGroup = tests / "Formatting"
            {
                tests.expect("\(hash)" ==? string)
            }
        }
        //  Test vectors from: https://datatracker.ietf.org/doc/html/rfc1321
        if  let tests:TestGroup = tests / "Empty"
        {
            let md5:MD5 = .init(hashing: [])
            tests.expect(md5 ==? 0xd41d8cd98f00b204e9800998ecf8427e)
        }
        if  let tests:TestGroup = tests / "I"
        {
            let md5:MD5 = .init(hashing: [0x61])
            tests.expect(md5 ==? 0x0cc175b9c0f1b6a831c399e269772661)
        }
        if  let tests:TestGroup = tests / "II"
        {
            let md5:MD5 = .init(hashing: [0x61, 0x62, 0x63])
            tests.expect(md5 ==? 0x900150983cd24fb0d6963f7d28e17f72)
        }
        if  let tests:TestGroup = tests / "III"
        {
            let md5:MD5 = .init(hashing: "message digest".utf8)
            tests.expect(md5 ==? 0xf96b697d7cb7938d525a2f31aaf161d0)
        }
        if  let tests:TestGroup = tests / "IV"
        {
            let md5:MD5 = .init(hashing: "abcdefghijklmnopqrstuvwxyz".utf8)
            tests.expect(md5 ==? 0xc3fcd3d76192e4007dfb496cca67e13b)
        }
        if  let tests:TestGroup = tests / "V"
        {
            let md5:MD5 = .init(hashing: """
                ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
                """.utf8)
            tests.expect(md5 ==? 0xd174ab98d277d9f5a5611c2c9f419d9f)
        }
        if  let tests:TestGroup = tests / "VI"
        {
            let md5:MD5 = .init(hashing: """
                12345678901234567890123456789012345678901234567890123456789012345678901234567890
                """.utf8)
            tests.expect(md5 ==? 0x57edf4a22be3c955ac49da2e2107b67a)
        }
    }
}
