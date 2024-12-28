extension SignatureSyntax
{
    @frozen @usableFromInline
    struct SugarMap
    {
        @usableFromInline
        var dictionaries:Set<Int>
        @usableFromInline
        var arrays:Set<Int>
        @usableFromInline
        var optionals:Set<Int>

        @inlinable
        init()
        {
            self.dictionaries = []
            self.arrays = []
            self.optionals = []
        }
    }
}
