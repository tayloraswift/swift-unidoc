extension SignatureSyntax
{
    @frozen @usableFromInline
    struct SugarMap
    {
        @usableFromInline
        var arrays:Set<Int>
        @usableFromInline
        var dictionaries:Set<Int>
        @usableFromInline
        var optionals:Set<Int>

        @inlinable
        init()
        {
            self.arrays = []
            self.dictionaries = []
            self.optionals = []
        }
    }
}
