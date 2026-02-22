import HTTP

extension HTTP.Accept {
    @frozen public struct Iterator {
        @usableFromInline var parser: HTTP.HeaderWords<HTTP.AcceptStringParameter, HTTP.Comma>

        @inlinable init(parser: HTTP.HeaderWords<HTTP.AcceptStringParameter, HTTP.Comma>) {
            self.parser = parser
        }
    }
}
extension HTTP.Accept.Iterator: IteratorProtocol {
    @inlinable public mutating func next() -> HTTP.Accept.Option? {
        while let parameter: HTTP.AcceptStringParameter = self.parser.next() {
            return .init(type: parameter.key, q: parameter.q ?? 1.0, v: parameter.v)
        }

        return nil
    }
}
