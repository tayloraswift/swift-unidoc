import HTTP
import Testing_
import Fingerprinting

extension Main
{
    struct AcceptTypeParsing
    {
    }
}
extension Main.AcceptTypeParsing:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Empty"
        {
            let header:HTTP.Accept = ""
            tests.expect(header ..? [])
        }
        if  let tests:TestGroup = tests / "Wildcard"
        {
            let header:HTTP.Accept = "*/*"
            tests.expect(header ..? [
                .init(type: "*/*", q: 1.0),
            ])
        }
        if  let tests:TestGroup = tests / "WildcardPattern"
        {
            let header:HTTP.Accept = "text/*"
            tests.expect(header ..? [
                .init(type: "text/*", q: 1.0),
            ])
        }
        if  let tests:TestGroup = tests / "HTML"
        {
            let header:HTTP.Accept = "text/html"
            tests.expect(header ..? [
                .init(type: "text/html", q: 1.0),
            ])
        }
        if  let tests:TestGroup = tests / "MultipleChoices"
        {
            let header:HTTP.Accept = """
            text/html, application/xhtml+xml, application/xml;q=0.9, image/webp, */*;q=0.8
            """
            tests.expect(header ..? [
                .init(type: "text/html", q: 1.0),
                .init(type: "application/xhtml+xml", q: 1.0),
                .init(type: "application/xml", q: 0.9),
                .init(type: "image/webp", q: 1.0),
                .init(type: "*/*", q: 0.8),
            ])
        }
        if  let tests:TestGroup = tests / "MultipleChoicesCompact"
        {
            let header:HTTP.Accept = """
            text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
            """
            tests.expect(header ..? [
                .init(type: "text/html", q: 1.0),
                .init(type: "application/xhtml+xml", q: 1.0),
                .init(type: "application/xml", q: 0.9),
                .init(type: "*/*", q: 0.8),
            ])
        }
        if  let tests:TestGroup = tests / "SignedExchange"
        {
            let header:HTTP.Accept = """
            text/html,application/xhtml+xml,\
            application/signed-exchange;v=b3,application/xml;q=0.9,*/*;q=0.8
            """
            tests.expect(header ..? [
                .init(type: "text/html", q: 1.0),
                .init(type: "application/xhtml+xml", q: 1.0),
                .init(type: "application/signed-exchange", q: 1.0, v: "b3"),
                .init(type: "application/xml", q: 0.9),
                .init(type: "*/*", q: 0.8),
            ])
        }
    }
}
