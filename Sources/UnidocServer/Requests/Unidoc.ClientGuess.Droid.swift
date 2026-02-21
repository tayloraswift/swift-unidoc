extension Unidoc.ClientGuess {
    @frozen public enum Droid: Equatable, Hashable, Sendable {
        case _bratz(score: Int)

        case lacksDominantLocale
        case lacksDominantAcceptHTML
    }
}
