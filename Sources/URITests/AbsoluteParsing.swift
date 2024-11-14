import Testing
import URI

@Suite
struct AbsoluteParsing
{
    @Test
    static func Empty() throws
    {
        #expect(URI.init("") == nil)
    }

    @Test
    static func OneSlash() throws
    {
        let uri:URI = try #require(.init("/"))
        #expect(uri.path == [])
    }

    @Test
    static func TwoSlashes() throws
    {
        let uri:URI = try #require(.init("//"))
        #expect(uri.path == ["", ""])
    }

    @Test
    static func OneComponent() throws
    {
        let uri:URI = try #require(.init("/abc"))
        #expect(uri.path == ["abc"])
    }

    @Test
    static func ManyComponents() throws
    {
        let uri:URI = try #require(.init("/abc/def/ghi"))
        #expect(uri.path == ["abc", "def", "ghi"])
    }

    @Test
    static func TrailingSlash() throws
    {
        let uri:URI = try #require(.init("/abc/"))
        #expect(uri.path == ["abc", ""])
    }

    @Test
    static func SpecialComponents() throws
    {
        let uri:URI = try #require(.init(#"//foo/bar/.\bax.qux/..//baz./.Foo/%2E%2E//"#))
        #expect(uri.path == [
                "",
                "foo",
                "bar",
                "",
                "bax.qux",
                .pop,
                "",
                "baz.",
                ".Foo",
                "..",
                "",
                ""
            ])
    }

    @Test
    static func Normalization() throws
    {
        let uri:URI = try #require(.init(#"//foo/bar/.\bax.qux/..//baz./.Foo/%2E%2E//"#))
        #expect(uri.path.normalized() == ["foo", "bar", "baz.", ".Foo", ".."])
    }

    @Test
    static func OverNormalization() throws
    {
        let uri:URI = try #require(.init("/abc/../../../../def"))
        #expect(uri.path.normalized() == ["def"])
    }
}
