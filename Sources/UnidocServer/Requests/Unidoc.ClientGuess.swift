import ISO

extension Unidoc {
    @frozen public enum ClientGuess: Equatable, Hashable, Sendable {
        case barbie(ISO.Locale)
        case droid(Droid)
        case robot(Robot)
    }
}
extension Unidoc.ClientGuess {
    var locale: ISO.Locale? {
        switch self {
        case .barbie(let locale):   locale
        case .droid:                nil
        case .robot(_):             nil
        }
    }
}
