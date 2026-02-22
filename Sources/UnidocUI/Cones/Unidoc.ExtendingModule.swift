extension Unidoc {
    struct ExtendingModule: Equatable, Hashable {
        let partisanship: Partisanship
        let index: Int32

        init(partisanship: Partisanship, index: Int32) {
            self.partisanship = partisanship
            self.index = index
        }
    }
}
extension Unidoc.ExtendingModule: Comparable {
    static func < (a: Self, b: Self) -> Bool {
        (a.partisanship, a.index) < (b.partisanship, b.index)
    }
}
