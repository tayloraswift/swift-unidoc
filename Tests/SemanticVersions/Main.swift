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
            tests.expect(SemanticVersion.init("0.1.2") ==? .init(0, 1, 2))
        }
        if  let tests:TestGroup = tests / "version-parsing" / "invalid"
        {
            if  let tests:TestGroup = tests / "empty"
            {
                tests.expect(nil: SemanticVersion.init(""))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(nil: SemanticVersion.init(".."))
            }
            if  let tests:TestGroup = tests / "non-numeric"
            {
                tests.expect(nil: SemanticVersion.init("x.y.z"))
            }
            if  let tests:TestGroup = tests / "negative"
            {
                tests.expect(nil: SemanticVersion.init("-1.0.0"))
            }
            if  let tests:TestGroup = tests / "two-components"
            {
                tests.expect(nil: SemanticVersion.init("1.2"))
            }
            if  let tests:TestGroup = tests / "four-components"
            {
                tests.expect(nil: SemanticVersion.init("1.2.3.4"))
            }
            if  let tests:TestGroup = tests / "leading-dot"
            {
                tests.expect(nil: SemanticVersion.init(".1.2.3"))
            }
            if  let tests:TestGroup = tests / "trailing-dot"
            {
                tests.expect(nil: SemanticVersion.init("1.2.3."))
            }
            if  let tests:TestGroup = tests / "overflow"
            {
                tests.expect(nil: SemanticVersion.init("0.1.99999"))
            }
        }
        if  let tests:TestGroup = tests / "mask-parsing" / "valid"
        {
            if  let tests:TestGroup = tests / "major"
            {
                tests.expect(SemanticVersionMask.init("1") ==? .major(1))
            }
            if  let tests:TestGroup = tests / "minor"
            {
                tests.expect(SemanticVersionMask.init("1.2") ==? .minor(1, 2))
            }
            if  let tests:TestGroup = tests / "patch"
            {
                tests.expect(SemanticVersionMask.init("1.2.3") ==? .patch(1, 2, 3))
            }
        }
        if  let tests:TestGroup = tests / "mask-parsing" / "invalid"
        {
            if  let tests:TestGroup = tests / "empty"
            {
                tests.expect(nil: SemanticVersionMask.init(""))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(nil: SemanticVersionMask.init(".."))
            }
            if  let tests:TestGroup = tests / "non-numeric"
            {
                tests.expect(nil: SemanticVersionMask.init("x.y.z"))
            }
            if  let tests:TestGroup = tests / "negative"
            {
                tests.expect(nil: SemanticVersionMask.init("-1.0.0"))
            }
            if  let tests:TestGroup = tests / "four-components"
            {
                tests.expect(nil: SemanticVersionMask.init("1.2.3.4"))
            }
            if  let tests:TestGroup = tests / "leading-dot"
            {
                tests.expect(nil: SemanticVersionMask.init(".1.2.3"))
            }
            if  let tests:TestGroup = tests / "trailing-dot"
            {
                tests.expect(nil: SemanticVersionMask.init("1.2.3."))
            }
            if  let tests:TestGroup = tests / "overflow"
            {
                tests.expect(nil: SemanticVersionMask.init("0.1.99999"))
            }
        }
    }
}
