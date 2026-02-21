extension Sorting {
    struct TestNode: Identifiable, Equatable {
        let id: String

        init(id: String) {
            self.id = id
        }
    }
}
extension Sorting.TestNode: CustomStringConvertible {
    var description: String { self.id }
}
extension Sorting.TestNode: ExpressibleByStringLiteral {
    init(stringLiteral: String) { self.init(id: stringLiteral) }
}
