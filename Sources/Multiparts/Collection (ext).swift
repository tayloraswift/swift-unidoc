extension Collection where Element: Equatable {
    func index(after start: Index, skipping sequence: some Sequence<Element>) -> Index? {
        var index: Index = start
        for element: Element in sequence {
            if  index < self.endIndex,
                element == self[index] {
                self.formIndex(after: &index)
            } else {
                return nil
            }
        }
        return index
    }
}
