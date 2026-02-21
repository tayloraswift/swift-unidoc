import HTTP

extension HTTP {
    @usableFromInline protocol HeaderWord {
        init?(_ word: Substring)
    }
}
