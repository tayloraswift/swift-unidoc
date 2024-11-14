import Testing
import URI

@Suite
struct FragmentParsing
{
    @Test
    static func Fragment() throws
    {
        let fragment:URI.Fragment = try #require(.init(decoding: "Parameters"))
        #expect(fragment.decoded == "Parameters")
    }

    @Test
    static func FragmentWithSpaces() throws
    {
        let fragment:URI.Fragment = try #require(.init(decoding: "Getting%20started"))
        #expect(fragment.decoded == "Getting started")
    }
}
