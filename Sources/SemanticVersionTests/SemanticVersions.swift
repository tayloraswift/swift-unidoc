import SemanticVersions
import Testing

@Suite
enum SemanticVersions
{
    @Test
    static func Release()
    {
        #expect(SemanticVersion.init("0.1.2") == .release(.v(0, 1, 2)))
    }
    @Test
    static func ReleaseV()
    {
        #expect(SemanticVersion.init(refname: "v0.1.2") == .release(.v(0, 1, 2)))
    }

    @Test
    static func Prerelease()
    {
        #expect(SemanticVersion.init(refname: "0.1.2-rc3") == .prerelease(.v(0, 1, 2), "rc3"))
    }
    @Test
    static func PrereleaseV()
    {
        #expect(SemanticVersion.init(refname: "v0.1.2-rc3") == .prerelease(.v(0, 1, 2), "rc3"))
    }
    @Test
    static func PrereleaseDashes()
    {
        #expect(SemanticVersion.init(refname: "600.0.0-prerelease-2024-04-25") ==
            .prerelease(.v(600, 0, 0), "prerelease-2024-04-25"))
    }

    @Test
    static func Build()
    {
        #expect(SemanticVersion.init(refname: "0.1.2+build3") ==
            .release(.v(0, 1, 2), build: "build3"))
    }
    @Test
    static func BuildV()
    {
        #expect(SemanticVersion.init(refname: "v0.1.2+build3") ==
            .release(.v(0, 1, 2), build: "build3"))
    }
    @Test
    static func BuildDashes()
    {
        #expect(SemanticVersion.init(refname: "v0.1.2+build-3") ==
            .release(.v(0, 1, 2), build: "build-3"))
    }

    @Test
    static func PrereleaseBuild()
    {
        #expect(SemanticVersion.init(refname: "0.1.2-rc3+build3") ==
            .prerelease(.v(0, 1, 2), "rc3", build: "build3"))
    }
    @Test
    static func PrereleaseBuildV()
    {
        #expect(SemanticVersion.init(refname: "v0.1.2-rc3+build3") ==
            .prerelease(.v(0, 1, 2), "rc3", build: "build3"))
    }
}
