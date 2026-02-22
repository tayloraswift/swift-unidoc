extension HTTP.CookieValue {
    @inlinable public init(
        _ value: String,
        _ configure: (inout HTTP.CookieEncoder) throws -> Void
    ) rethrows {
        var encoder: HTTP.CookieEncoder = .init(string: value)
        try configure(&encoder)
        self.init(encoder.string)
    }
}
