extension HTTP {
    @frozen public struct Redirect: Equatable, Sendable {
        public let target: Target
        @usableFromInline let code: Code

        @inlinable init(target: Target, code: Code) {
            self.target = target
            self.code = code
        }
    }
}
extension HTTP.Redirect {
    @inlinable public var status: UInt {
        switch self.code {
        case .seeOther:  303
        case .temporary: 307
        case .permanent: 308
        }
    }
}
extension HTTP.Redirect {
    @inlinable public static func permanent(external location: String) -> Self {
        .init(target: .external(location), code: .permanent)
    }

    @inlinable public static func permanent(_ location: String) -> Self {
        .init(target: .domestic(location), code: .permanent)
    }

    @inlinable public static func temporary(_ location: String) -> Self {
        .init(target: .domestic(location), code: .temporary)
    }

    @inlinable public static func seeOther(_ location: String) -> Self {
        .init(target: .domestic(location), code: .seeOther)
    }
}
