import SymbolGraphs

extension SSGC.Outliner {
    /// This is just keyed by ``String`` and not ``Markdown.SourceString``, otherwise caching
    /// would be pointless. Because link resolution varies depending on where the markdown
    /// containing the link is located, this means the cache is only valid for a single
    /// ``Markdown.Source``.
    struct Cache {
        private var outlined: Outputs
        private var entries: [String: Int]

        init() {
            self.outlined = .init()
            self.entries = [:]
        }
    }
}
extension SSGC.Outliner.Cache {
    var fold: Int { self.outlined.outlines.endIndex }

    mutating func add(outline: SymbolGraph.Outline) -> Int {
        self.outlined.add(outline: outline)
    }

    mutating func clear() -> [SymbolGraph.Outline] {
        defer { self = .init() }
        return self.outlined.outlines
    }

    mutating func callAsFunction(
        _ key: String,
        with populate: () throws -> SymbolGraph.Outline?
    ) rethrows -> Int? {
        try {
            if  let reference: Int = $0 {
                return reference
            } else if
                let outline: SymbolGraph.Outline = try populate() {
                //  Sometimes we get the same outline from different keys. As an optimization,
                //  we can reuse an existing outline.
                let outline: Int = self.outlined.add(outline: outline)
                $0 = outline
                return outline
            } else {
                return nil
            }
        } (&self.entries[key])
    }
}
