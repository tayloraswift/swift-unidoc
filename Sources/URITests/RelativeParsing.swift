import Testing
import URI

@Suite
struct RelativeParsing
{
    @Test
    static func Empty() throws
    {
        let path:URI.Path = try #require(.init(relative: ""))
        #expect(path == [])
    }

    @Test
    static func OneSlash() throws
    {
        let path:URI.Path = try #require(.init(relative: "/"))
        #expect(path == ["", ""])
    }

    @Test
    static func TwoSlashes() throws
    {
        let path:URI.Path = try #require(.init(relative: "//"))
        #expect(path == ["", "", ""])
    }

    @Test
    static func LeadingSlash() throws
    {
        let path:URI.Path = try #require(.init(relative: "/abc"))
        #expect(path == ["", "abc"])
    }

    @Test
    static func LeadingAndTrailingSlash() throws
    {
        let path:URI.Path = try #require(.init(relative: "/abc/"))
        #expect(path == ["", "abc", ""])
    }

    @Test
    static func TrailingSlash() throws
    {
        let path:URI.Path = try #require(.init(relative: "abc/"))
        #expect(path == ["abc", ""])
    }

    @Test
    static func OneComponent() throws
    {
        let path:URI.Path = try #require(.init(relative: "abc"))
        #expect(path == ["abc"])
    }

    @Test
    static func EmptyComponent() throws
    {
        let path:URI.Path = try #require(.init(relative: "."))
        #expect(path == [""])
    }

    @Test
    static func PopComponent() throws
    {
        let path:URI.Path = try #require(.init(relative: ".."))
        #expect(path == [.pop])
    }
}
