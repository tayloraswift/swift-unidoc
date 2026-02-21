import HTTP

extension HTTP.CookieList {
    @frozen public struct Iterator {
        @usableFromInline var parser: HTTP.HeaderWords<HTTP.Cookie, HTTP.Semicolon>

        @inlinable init(parser: HTTP.HeaderWords<HTTP.Cookie, HTTP.Semicolon>) {
            self.parser = parser
        }
    }
}
extension HTTP.CookieList.Iterator: IteratorProtocol {
    @inlinable public mutating func next() -> HTTP.Cookie? { self.parser.next() }
}
