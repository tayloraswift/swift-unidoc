import SemanticVersions
import Testing

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "SemanticVersion" / "Release"
        {
            tests.expect(SemanticVersion.init("0.1.2") ==? .release(.v(0, 1, 2)))
        }
        if  let tests:TestGroup = tests / "SemanticVersion" / "Release" / "V"
        {
            tests.expect(SemanticVersion.init(refname: "v0.1.2") ==? .release(.v(0, 1, 2)))
        }

        if  let tests:TestGroup = tests / "SemanticVersion" / "Prerelease"
        {
            tests.expect(SemanticVersion.init(refname: "0.1.2-rc3") ==?
                .prerelease(.v(0, 1, 2), "rc3"))
        }
        if  let tests:TestGroup = tests / "SemanticVersion" / "Prerelease" / "V"
        {
            tests.expect(SemanticVersion.init(refname: "v0.1.2-rc3") ==?
                .prerelease(.v(0, 1, 2), "rc3"))
        }

        if  let tests:TestGroup = tests / "SemanticVersion" / "Build"
        {
            tests.expect(SemanticVersion.init(refname: "0.1.2+build3") ==?
                .release(.v(0, 1, 2), build: "build3"))
        }
        if  let tests:TestGroup = tests / "SemanticVersion" / "Build" / "V"
        {
            tests.expect(SemanticVersion.init(refname: "v0.1.2+build3") ==?
                .release(.v(0, 1, 2), build: "build3"))
        }

        if  let tests:TestGroup = tests / "SemanticVersion" / "PrereleaseBuild"
        {
            tests.expect(SemanticVersion.init(refname: "0.1.2-rc3+build3") ==?
                .prerelease(.v(0, 1, 2), "rc3", build: "build3"))
        }
        if  let tests:TestGroup = tests / "SemanticVersion" / "PrereleaseBuild" / "V"
        {
            tests.expect(SemanticVersion.init(refname: "v0.1.2-rc3+build3") ==?
                .prerelease(.v(0, 1, 2), "rc3", build: "build3"))
        }

        if  let tests:TestGroup = tests / "PatchVersion" / "Valid"
        {
            tests.expect(PatchVersion.init("0.1.2") ==? .v(0, 1, 2))
        }
        if  let tests:TestGroup = tests / "PatchVersion" / "Invalid"
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
        if  let tests:TestGroup = tests / "NumericVersion" / "Valid"
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
        if  let tests:TestGroup = tests / "NumericVersion" / "Invalid"
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
