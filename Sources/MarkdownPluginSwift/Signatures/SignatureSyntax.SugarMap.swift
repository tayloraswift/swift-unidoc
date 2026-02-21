extension SignatureSyntax {
    @frozen @usableFromInline struct SugarMap {
        /// The value that will be substituted for residual `` `Self` `` tokens when generating
        /// autographs.
        ///
        /// This exists to correct for an
        /// [upstream bug in the Swift compiler](https://github.com/swiftlang/swift/issues/78343),
        /// and does not affect human-visible signature fragments.
        @usableFromInline let staticSelf: String?

        @usableFromInline var dictionaries: Set<Int>
        @usableFromInline var arrays: Set<Int>
        @usableFromInline var optionals: Set<Int>

        @inlinable init(staticSelf: String?) {
            self.staticSelf = staticSelf
            self.dictionaries = []
            self.arrays = []
            self.optionals = []
        }
    }
}
