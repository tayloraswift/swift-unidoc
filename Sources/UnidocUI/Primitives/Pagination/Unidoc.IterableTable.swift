import URI

extension Unidoc {
    protocol IterableTable {
        func more(page index: Int) -> URI
    }
}
