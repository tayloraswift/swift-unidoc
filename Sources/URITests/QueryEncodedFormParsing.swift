import Testing
import URI

@Suite
struct QueryFormParsing
{
    @Test
    static func Empty() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "")
        #expect(form.parameters == [])
    }
    @Test
    static func One() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=bar")
        #expect(form.parameters == [("foo", "bar")])
    }
    @Test
    static func Two() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=bar&baz=qux")
        #expect(form.parameters == [("foo", "bar"), ("baz", "qux")])
    }

    @Test
    static func TwoWithSemicolon() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=bar;baz=qux")
        #expect(form.parameters == [("foo", "bar"), ("baz", "qux")])
    }

    @Test
    static func TwoWithEmptyValues() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=&baz=")
        #expect(form.parameters == [("foo", ""), ("baz", "")])
    }

    @Test
    static func PlusEncodedSpace() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=bar+baz")
        #expect(form.parameters == [("foo", "bar baz")])
    }

    @Test
    static func PercentEncodedSpace() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=bar%20baz")
        #expect(form.parameters == [("foo", "bar baz")])
    }

    @Test
    static func PercentEncodedPlus() throws
    {
        let form:URI.QueryEncodedForm = try .parse(parameters: "foo=bar%2Bbaz")
        #expect(form.parameters == [("foo", "bar+baz")])
    }
}
