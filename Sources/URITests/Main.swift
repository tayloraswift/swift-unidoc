import Testing
import URI

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "Parsing"
        {
            if  let tests:TestGroup = tests / "Relative" / "Empty",
                let path:URI.Path = tests.expect(value: .init(relative: ""))
            {
                tests.expect(path ==? [])
            }
            if  let tests:TestGroup = tests / "Relative" / "OneSlash",
                let path:URI.Path = tests.expect(value: .init(relative: "/"))
            {
                tests.expect(path ==? ["", ""])
            }
            if  let tests:TestGroup = tests / "Relative" / "TwoSlashes",
                let path:URI.Path = tests.expect(value: .init(relative: "//"))
            {
                tests.expect(path ==? ["", "", ""])
            }
            if  let tests:TestGroup = tests / "Relative" / "LeadingSlash",
                let path:URI.Path = tests.expect(value: .init(relative: "/abc"))
            {
                tests.expect(path ==? ["", "abc"])
            }
            if  let tests:TestGroup = tests / "Relative" / "LeadingAndTrailingSlash",
                let path:URI.Path = tests.expect(value: .init(relative: "/abc/"))
            {
                tests.expect(path ==? ["", "abc", ""])
            }
            if  let tests:TestGroup = tests / "Relative" / "TrailingSlash",
                let path:URI.Path = tests.expect(value: .init(relative: "abc/"))
            {
                tests.expect(path ==? ["abc", ""])
            }
            if  let tests:TestGroup = tests / "Relative" / "OneComponent",
                let path:URI.Path = tests.expect(value: .init(relative: "abc"))
            {
                tests.expect(path ==? ["abc"])
            }
            if  let tests:TestGroup = tests / "Relative" / "EmptyComponent",
                let path:URI.Path = tests.expect(value: .init(relative: "."))
            {
                tests.expect(path ==? [""])
            }
            if  let tests:TestGroup = tests / "Relative" / "PopComponent",
                let path:URI.Path = tests.expect(value: .init(relative: ".."))
            {
                tests.expect(path ==? [.pop])
            }

            if  let tests:TestGroup = tests / "Empty"
            {
                tests.expect(nil: URI.init(""))
            }
            if  let tests:TestGroup = tests / "OneSlash",
                let uri:URI = tests.expect(value: .init("/"))
            {
                tests.expect(uri.path ==? [])
            }
            if  let tests:TestGroup = tests / "TwoSlashes",
                let uri:URI = tests.expect(value: .init("//"))
            {
                tests.expect(uri.path ==? ["", ""])
            }
            if  let tests:TestGroup = tests / "OneComponent",
                let uri:URI = tests.expect(value: .init("/abc"))
            {
                tests.expect(uri.path ==? ["abc"])
            }
            if  let tests:TestGroup = tests / "ManyComponents",
                let uri:URI = tests.expect(value: .init("/abc/def/ghi"))
            {
                tests.expect(uri.path ==? ["abc", "def", "ghi"])
            }
            if  let tests:TestGroup = tests / "TrailingSlash",
                let uri:URI = tests.expect(value: .init("/abc/"))
            {
                tests.expect(uri.path ==? ["abc", ""])
            }
            if  let tests:TestGroup = tests / "SpecialComponents",
                let uri:URI = tests.expect(
                    value: .init(#"//foo/bar/.\bax.qux/..//baz./.Foo/%2E%2E//"#))
            {
                tests.expect(uri.path ==?
                    ["", "foo", "bar", "", "bax.qux", .pop, "", "baz.", ".Foo", "..", "", ""])
            }
            if  let tests:TestGroup = tests / "Normalization",
                let uri:URI = tests.expect(
                    value: .init(#"//foo/bar/.\bax.qux/..//baz./.Foo/%2E%2E//"#))
            {
                tests.expect(uri.path.normalized() ==? ["foo", "bar", "baz.", ".Foo", ".."])
            }
            if  let tests:TestGroup = tests / "OverNormalization",
                let uri:URI = tests.expect(value: .init("/abc/../../../../def"))
            {
                tests.expect(uri.path.normalized() ==? ["def"])
            }
        }
    }
}
