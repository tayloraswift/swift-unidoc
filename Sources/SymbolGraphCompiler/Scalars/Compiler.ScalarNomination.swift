extension Compiler
{
    @usableFromInline @frozen internal
    enum ScalarNomination:Equatable, Hashable, Sendable
    {
        case feature(String, ScalarPhylum)
        case heir([String])
    }
}
