import SemanticVersions
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "version-parsing" / "valid"
        {
            tests.expect(PatchVersion.init("0.1.2") ==? .v(0, 1, 2))
        }
        if  let tests:TestGroup = tests / "version-parsing" / "invalid"
        {
            if  let tests:TestGroup = tests / "empty"
            {
                tests.expect(nil: PatchVersion.init(""))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(nil: PatchVersion.init(".."))
            }
            if  let tests:TestGroup = tests / "non-numeric"
            {
                tests.expect(nil: PatchVersion.init("x.y.z"))
            }
            if  let tests:TestGroup = tests / "negative"
            {
                tests.expect(nil: PatchVersion.init("-1.0.0"))
            }
            if  let tests:TestGroup = tests / "two-components"
            {
                tests.expect(nil: PatchVersion.init("1.2"))
            }
            if  let tests:TestGroup = tests / "four-components"
            {
                tests.expect(nil: PatchVersion.init("1.2.3.4"))
            }
            if  let tests:TestGroup = tests / "leading-dot"
            {
                tests.expect(nil: PatchVersion.init(".1.2.3"))
            }
            if  let tests:TestGroup = tests / "trailing-dot"
            {
                tests.expect(nil: PatchVersion.init("1.2.3."))
            }
            if  let tests:TestGroup = tests / "overflow"
            {
                tests.expect(nil: PatchVersion.init("0.1.99999"))
            }
        }
        if  let tests:TestGroup = tests / "mask-parsing" / "valid"
        {
            if  let tests:TestGroup = tests / "major"
            {
                tests.expect(NumericVersion.init("1") ==? .major(.v(1)))
            }
            if  let tests:TestGroup = tests / "minor"
            {
                tests.expect(NumericVersion.init("1.2") ==? .minor(.v(1, 2)))
            }
            if  let tests:TestGroup = tests / "patch"
            {
                tests.expect(NumericVersion.init("1.2.3") ==? .patch(.v(1, 2, 3)))
            }
        }
        if  let tests:TestGroup = tests / "mask-parsing" / "invalid"
        {
            if  let tests:TestGroup = tests / "empty"
            {
                tests.expect(nil: NumericVersion.init(""))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(nil: NumericVersion.init(".."))
            }
            if  let tests:TestGroup = tests / "non-numeric"
            {
                tests.expect(nil: NumericVersion.init("x.y.z"))
            }
            if  let tests:TestGroup = tests / "negative"
            {
                tests.expect(nil: NumericVersion.init("-1.0.0"))
            }
            if  let tests:TestGroup = tests / "four-components"
            {
                tests.expect(nil: NumericVersion.init("1.2.3.4"))
            }
            if  let tests:TestGroup = tests / "leading-dot"
            {
                tests.expect(nil: NumericVersion.init(".1.2.3"))
            }
            if  let tests:TestGroup = tests / "trailing-dot"
            {
                tests.expect(nil: NumericVersion.init("1.2.3."))
            }
            if  let tests:TestGroup = tests / "overflow"
            {
                tests.expect(nil: NumericVersion.init("0.1.99999"))
            }
        }
    }
}
