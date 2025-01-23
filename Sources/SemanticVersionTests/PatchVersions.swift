import SemanticVersions
import Testing

@Suite
enum PatchVersions
{
    @Test
    static func Valid()
    {
        #expect(PatchVersion.init("0.1.2") == .v(0, 1, 2))
    }
    @Test
    static func InvalidEmpty()
    {
        #expect(nil == PatchVersion.init(""))
    }
    @Test
    static func InvalidDots()
    {
        #expect(nil == PatchVersion.init(".."))
    }
    @Test
    static func InvalidNonNumeric()
    {
        #expect(nil == PatchVersion.init("x.y.z"))
    }
    @Test
    static func InvalidTwoComponents()
    {
        #expect(nil == PatchVersion.init("1.2"))
    }
    @Test
    static func InvalidFourComponents()
    {
        #expect(nil == PatchVersion.init("1.2.3.4"))
    }
    @Test
    static func InvalidLeadingDot()
    {
        #expect(nil == PatchVersion.init(".1.2.3"))
    }
    @Test
    static func InvalidTrailingDot()
    {
        #expect(nil == PatchVersion.init("1.2.3."))
    }
    @Test
    static func Overflow()
    {
        #expect(nil == PatchVersion.init("0.1.99999"))
    }
}
