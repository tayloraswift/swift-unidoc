extension HTTP.Redirect {
    @frozen @usableFromInline enum Code: Equatable, Sendable {
        case seeOther
        case temporary
        case permanent
    }
}
