import Symbols
import Testing

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Empty"
        {
            tests.expect(nil: Symbol.USR.init(""))
        }
        if  let tests:TestGroup = tests / "EmptySuffix"
        {
            tests.expect(nil: Symbol.USR.init("s:"))
        }

        if  let tests:TestGroup = tests / "Scalar"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init("s:s12IdentifiableP"))
            {
                tests.expect(usr ==? .scalar(.init(.s, ascii: "s12IdentifiableP")))
            }
        }
        if  let tests:TestGroup = tests / "Scalar" / "InvalidLanguage"
        {
            tests.expect(nil: Symbol.USR.init("ss:s12IdentifiableP"))
        }
        if  let tests:TestGroup = tests / "Scalar" / "InvalidCharacters"
        {
            tests.expect(nil: Symbol.USR.init("s:s12Identifi+ableP"))
        }

        if  let tests:TestGroup = tests / "Compound"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init(
                    "s:s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:Sq"))
            {
                tests.expect(usr ==?
                    .vector(.init(.init(.s, ascii: "s12IdentifiablePsRlzCrlE2idSOvp"),
                        self: .init(.s, ascii: "Sq"))))
            }
        }
        if  let tests:TestGroup = tests / "Compound" / "InvalidPrefix"
        {
            tests.expect(nil: Symbol.USR.init(
                    ":s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:Sq"))
        }
        if  let tests:TestGroup = tests / "Compound" / "InvalidInfix"
        {
            tests.expect(nil: Symbol.USR.init(
                    "s:s12IdentifiablePsRlzCrlE2idSOvp::LASERTITTIES::s:Sq"))
        }
        if  let tests:TestGroup = tests / "Compound" / "InvalidSuffix"
        {
            tests.expect(nil: Symbol.USR.init(
                "s:s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:"))
        }

        if  let tests:TestGroup = tests / "Block" / "FirstMember"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init(
                    "s:e:s:Sq17ZooExtensionsDeepSiRszlE2ids5NeverOvp"))
            {
                tests.expect(usr ==? .block(.init(
                    name: "s:Sq17ZooExtensionsDeepSiRszlE2ids5NeverOvp")))
            }
        }
        if  let tests:TestGroup = tests / "Block" / "FirstConformance"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init("s:e:s:Sqs:s8SendableP"))
            {
                tests.expect(usr ==? .block(.init(name: "s:Sqs:s8SendableP")))
            }
        }
        if  let tests:TestGroup = tests / "Block" / "Gibberish"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init("s:e: \n!\u{0} 🇺🇸"))
            {
                tests.expect(usr ==? .block(.init(name: " \n!\u{0} 🇺🇸")))
            }
        }
        if  let tests:TestGroup = tests / "Block" / "Empty"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init("s:e:"))
            {
                tests.expect(usr ==? .block(.init(name: "")))
            }
        }
    }
}
