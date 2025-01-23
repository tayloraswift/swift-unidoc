import SemanticVersions
import Testing

@Suite
enum NumericVersions
{
    @Test
    static func ValidMajor()
    {
        #expect(NumericVersion.init("1") == .major(.v(1)))
    }
    @Test
    static func ValidMinor()
    {
        #expect(NumericVersion.init("1.2") == .minor(.v(1, 2)))
    }
    @Test
    static func ValidPatch()
    {
        #expect(NumericVersion.init("1.2.3") == .patch(.v(1, 2, 3)))
    }
    @Test
    static func InvalidEmpty()
    {
        #expect(nil == NumericVersion.init(""))
    }
    @Test
    static func InvalidDots()
    {
        #expect(nil == NumericVersion.init(".."))
    }
    @Test
    static func InvalidNonNumeric()
    {
        #expect(nil == NumericVersion.init("x.y.z"))
    }
    @Test
    static func InvalidFourComponents()
    {
        #expect(nil == NumericVersion.init("1.2.3.4"))
    }
    @Test
    static func InvalidLeadingDot()
    {
        #expect(nil == NumericVersion.init(".1.2.3"))
    }
    @Test
    static func InvalidTrailingDot()
    {
        #expect(nil == NumericVersion.init("1.2.3."))
    }
    @Test
    static func InvalidOverflow()
    {
        #expect(nil == NumericVersion.init("0.1.99999"))
    }
}
