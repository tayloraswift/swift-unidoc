import Symbols
import Testing

@Suite
enum Parsing
{
    @Test
    static func Empty()
    {
        #expect(nil == Symbol.USR.init(""))
    }
    @Test
    static func EmptySuffix()
    {
        #expect(nil == Symbol.USR.init("s:"))
    }

    @Test
    static func Scalar()
    {
        let expected:Symbol.Decl = .init(.s, ascii: "s12IdentifiableP")
        #expect(Symbol.USR.init("s:s12IdentifiableP") == .scalar(expected))
    }
    @Test
    static func ScalarInvalidLanguage()
    {
        #expect(nil == Symbol.USR.init("ss:s12IdentifiableP"))
    }
    @Test
    static func ScalarInvalidCharacters()
    {
        #expect(nil == Symbol.USR.init("s:s12Identifi ableP"))
    }

    @Test
    static func Compound()
    {
        let expected:Symbol.Decl.Vector = .init(.init(.s, ascii: """
                s12IdentifiablePsRlzCrlE2idSOvp
                """),
            self: .init(.s, ascii: "Sq"))
        #expect(Symbol.USR.init(
            "s:s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:Sq") == .vector(expected))
    }
    @Test
    static func CompoundInvalidPrefix()
    {
        #expect(nil == Symbol.USR.init(
            ":s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:Sq"))
    }
    @Test
    static func CompoundInvalidInfix()
    {
        #expect(nil == Symbol.USR.init(
            "s:s12IdentifiablePsRlzCrlE2idSOvp::LASERTITTIES::s:Sq"))
    }
    @Test
    static func CompoundInvalidSuffix()
    {
        #expect(nil == Symbol.USR.init(
            "s:s12IdentifiablePsRlzCrlE2idSOvp::SYNTHESIZED::s:"))
    }

    @Test
    static func MacroDollarIdentifier()
    {
        let expected:Symbol.Decl.Vector = .init(.init(.s, ascii: """
                9FluentKit5ModelPAAE4_$idAA10IDPropertyCyx7IDValueQzGvp
                """),
            self: .init(.s, ascii: "17HummingbirdFluent12PersistModelC"))

        #expect(Symbol.USR.init("""
            s:9FluentKit5ModelPAAE4_$idAA10IDPropertyCyx7IDValueQzGvp\
            ::SYNTHESIZED::s:17HummingbirdFluent12PersistModelC
            """) == .vector(expected))
    }

    @Test
    static func ObjectiveC()
    {
        let expected:Symbol.Decl = .init(.c, ascii: """
            @CM@Alamofire@objc(cs)SessionDelegate(im)URLSession\
            :webSocketTask:didOpenWithProtocol:
            """)
        #expect(Symbol.USR.init("""
            c:@CM@Alamofire@objc(cs)SessionDelegate(im)URLSession\
            :webSocketTask:didOpenWithProtocol:
            """) == .scalar(expected))
    }

    @Test
    static func Chimaeric()
    {
        let expected:Symbol.Decl.Vector = .init(.init(.s, ascii: "SQsE2neoiySbx_xtFZ"),
            self: .init(.c, ascii: "@E@memory_order"))
        #expect(Symbol.USR.init("""
            s:SQsE2neoiySbx_xtFZ::SYNTHESIZED::c:@E@memory_order
            """) == .vector(expected))
    }

    @Test
    static func BlockFirstMember()
    {
        #expect(Symbol.USR.init("""
            s:e:s:Sq17ZooExtensionsDeepSiRszlE2ids5NeverOvp
            """) == .block(.init(name: "s:Sq17ZooExtensionsDeepSiRszlE2ids5NeverOvp")))
    }
    @Test
    static func BlockFirstConformance()
    {
        #expect(Symbol.USR.init("""
            s:e:s:Sqs:s8SendableP
            """) == .block(.init(name: "s:Sqs:s8SendableP")))
    }
    @Test
    static func BlockGibberish()
    {
        #expect(Symbol.USR.init("s:e: \n!\u{0} 🇺🇸") == .block(.init(name: " \n!\u{0} 🇺🇸")))
    }
    @Test
    static func BlockEmpty()
    {
        #expect(Symbol.USR.init("s:e:") == .block(.init(name: "")))
    }
}
