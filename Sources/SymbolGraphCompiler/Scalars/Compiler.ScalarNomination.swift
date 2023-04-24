extension Compiler
{
    @usableFromInline @frozen internal
    enum ScalarNomination:Equatable, Hashable, Sendable
    {
        case feature(String)
        case heir([String])
    }
}
