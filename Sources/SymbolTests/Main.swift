import Symbols
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "empty"
        {
            tests.expect(nil: Symbol.init(""))
        }
        if  let tests:TestGroup = tests / "empty-suffix"
        {
            tests.expect(nil: Symbol.init("s:"))
        }

        if  let tests:TestGroup = tests / "scalar"
        {
            if  let usr:Symbol = tests.expect(value: .init("s:s12IdentifiableP"))
            {
                tests.expect(usr ==? .scalar(.init(.s, ascii: "s12IdentifiableP")))
            }
        }
        if  let tests:TestGroup = tests / "scalar" / "invalid-language"
        {
            tests.expect(nil: Symbol.init("ss:s12IdentifiableP"))
        }
        if  let tests:TestGroup = tests / "scalar" / "invalid-characters"
        {
            tests.expect(nil: Symbol.init("s:s12Identifi+ableP"))
        }

        if  let tests:TestGroup = tests / "compound"
        {
            if  let usr:Symbol = tests.expect(value: .init(
                    "s:s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:Sq"))
            {
                tests.expect(usr ==?
                    .vector(.init(.init(.s, ascii: "s12IdentifiablePsRlzCrlE2idSOvp"),
                        self: .init(.s, ascii: "Sq"))))
            }
        }
        if  let tests:TestGroup = tests / "compound" / "invalid-prefix"
        {
            tests.expect(nil: Symbol.init(
                    ":s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:Sq"))
        }
        if  let tests:TestGroup = tests / "compound" / "invalid-infix"
        {
            tests.expect(nil: Symbol.init(
                    "s:s12IdentifiablePsRlzCrlE2idSOvp::LASERTITTIES::s:Sq"))
        }
        if  let tests:TestGroup = tests / "compound" / "invalid-suffix"
        {
            tests.expect(nil: Symbol.init(
                "s:s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:"))
        }

        if  let tests:TestGroup = tests / "block" / "first-member"
        {
            if  let usr:Symbol = tests.expect(value: .init(
                    "s:e:s:Sq17ZooExtensionsDeepSiRszlE2ids5NeverOvp"))
            {
                tests.expect(usr ==? .block(.init(
                    name: "s:Sq17ZooExtensionsDeepSiRszlE2ids5NeverOvp")))
            }
        }
        if  let tests:TestGroup = tests / "block" / "first-conformance"
        {
            if  let usr:Symbol = tests.expect(value: .init("s:e:s:Sqs:s8SendableP"))
            {
                tests.expect(usr ==? .block(.init(name: "s:Sqs:s8SendableP")))
            }
        }
        if  let tests:TestGroup = tests / "block" / "gibberish"
        {
            if  let usr:Symbol = tests.expect(value: .init("s:e: \n!\u{0} 🇺🇸"))
            {
                tests.expect(usr ==? .block(.init(name: " \n!\u{0} 🇺🇸")))
            }
        }
        if  let tests:TestGroup = tests / "block" / "empty"
        {
            if  let usr:Symbol = tests.expect(value: .init("s:e:"))
            {
                tests.expect(usr ==? .block(.init(name: "")))
            }
        }
    }
}
