extension HTTP {
    @frozen public struct CookieEncoder {
        @usableFromInline var string: String

        @inlinable init(string: String) {
            self.string = string
        }
    }
}
extension HTTP.CookieEncoder {
    @inlinable public var maxAge: Int? {
        get { nil }
        set (value) { value.map { self.string += "; Max-Age=\($0)" } }
    }

    @inlinable public var sameSite: SameSite? {
        get { nil }
        set (value) { value.map { self.string += "; SameSite=\($0)" } }
    }

    @inlinable public var domain: String? {
        get { nil }
        set (value) { value.map { self.string += "; Domain=\($0)" } }
    }

    @inlinable public var path: String? {
        get { nil }
        set (value) { value.map { self.string += "; Path=\($0)" } }
    }

    @inlinable public var httpOnly: Bool {
        get { false }
        set (value) {
            if  value {
                self.string += "; HttpOnly"
            }
        }
    }

    @inlinable public var secure: Bool {
        get { false }
        set (value) {
            if  value {
                self.string += "; Secure"
            }
        }
    }
}
