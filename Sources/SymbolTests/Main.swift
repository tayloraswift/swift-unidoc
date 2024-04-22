import Symbols
import Testing_

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

        if  let tests:TestGroup = tests / "MacroDollarIdentifier"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init("""
                    s:9FluentKit5ModelPAAE4_$idAA10IDPropertyCyx7IDValueQzGvp\
                    ::SYNTHESIZED::s:17HummingbirdFluent12PersistModelC
                    """))
            {
                tests.expect(usr ==? .vector(.init(.init(.s,
                        ascii: "9FluentKit5ModelPAAE4_$idAA10IDPropertyCyx7IDValueQzGvp"),
                    self: .init(.s,
                        ascii: "17HummingbirdFluent12PersistModelC"))))
            }
        }

        if  let tests:TestGroup = tests / "ObjectiveC"
        {
            if  let usr:Symbol.USR = tests.expect(value: .init("""
                    c:@CM@Alamofire@objc(cs)SessionDelegate(im)URLSession\
                    :webSocketTask:didOpenWithProtocol:
                    """))
            {
                tests.expect(usr ==? .scalar(.init(.c,
                    ascii: """
                    @CM@Alamofire@objc(cs)SessionDelegate(im)URLSession\
                    :webSocketTask:didOpenWithProtocol:
                    """)))
            }
        }

        if  let tests:TestGroup = tests / "Chimaeric"
        {
            if  let usr:Symbol.USR = tests.expect(
                    value: .init("s:SQsE2neoiySbx_xtFZ::SYNTHESIZED::c:@E@memory_order"))
            {
                tests.expect(usr ==? .vector(.init(.init(.s,
                        ascii: "SQsE2neoiySbx_xtFZ"),
                    self: .init(.c,
                        ascii: "@E@memory_order"))))
            }
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
