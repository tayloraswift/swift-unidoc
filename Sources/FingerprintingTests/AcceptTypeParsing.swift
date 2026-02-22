import Fingerprinting
import HTTP
import Testing

@Suite struct AcceptTypeParsing {
    @Test static func Empty() {
        let header: HTTP.Accept = ""
        #expect([_].init(header) == [])
    }
    @Test static func Wildcard() {
        let header: HTTP.Accept = "*/*"
        #expect(
            [_].init(header) == [
                .init(type: "*/*", q: 1.0),
            ]
        )
    }
    @Test static func WildcardPattern() {
        let header: HTTP.Accept = "text/*"
        #expect(
            [_].init(header) == [
                .init(type: "text/*", q: 1.0),
            ]
        )
    }
    @Test static func HTML() {
        let header: HTTP.Accept = "text/html"
        #expect(
            [_].init(header) == [
                .init(type: "text/html", q: 1.0),
            ]
        )
    }
    @Test static func MultipleChoices() {
        let header: HTTP.Accept = """
        text/html, application/xhtml+xml, application/xml;q=0.9, image/webp, */*;q=0.8
        """
        #expect(
            [_].init(header) == [
                .init(type: "text/html", q: 1.0),
                .init(type: "application/xhtml+xml", q: 1.0),
                .init(type: "application/xml", q: 0.9),
                .init(type: "image/webp", q: 1.0),
                .init(type: "*/*", q: 0.8),
            ]
        )
    }
    @Test static func MultipleChoicesCompact() {
        let header: HTTP.Accept = """
        text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
        """
        #expect(
            [_].init(header) == [
                .init(type: "text/html", q: 1.0),
                .init(type: "application/xhtml+xml", q: 1.0),
                .init(type: "application/xml", q: 0.9),
                .init(type: "*/*", q: 0.8),
            ]
        )
    }
    @Test static func SignedExchange() {
        let header: HTTP.Accept = """
        text/html,application/xhtml+xml,\
        application/signed-exchange;v=b3,application/xml;q=0.9,*/*;q=0.8
        """
        #expect(
            [_].init(header) == [
                .init(type: "text/html", q: 1.0),
                .init(type: "application/xhtml+xml", q: 1.0),
                .init(type: "application/signed-exchange", q: 1.0, v: "b3"),
                .init(type: "application/xml", q: 0.9),
                .init(type: "*/*", q: 0.8),
            ]
        )
    }
}
