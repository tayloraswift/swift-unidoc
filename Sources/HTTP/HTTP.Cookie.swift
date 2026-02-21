extension HTTP {
    @frozen public struct Cookie: Equatable, Hashable, Sendable {
        public let name: Substring
        public let value: Substring

        @inlinable public init(name: Substring = "", value: Substring) {
            self.name = name
            self.value = value
        }
    }
}
extension HTTP.Cookie {
    @inlinable public init?(_ cookie: Substring) {
        if  let equals: String.Index = cookie.firstIndex(of: "=") {
            let start: String.Index = cookie.index(after: equals)
            self.init(name: cookie[..<equals], value: cookie[start...])
        } else if !cookie.isEmpty {
            self.init(value: cookie)
        } else {
            return nil
        }
    }
}
