import UCF

extension SSGC {
    struct AnchorTable {
        private let scope: Int32?
        private var table: [UCF.AnchorMangling: String]

        init(scope: Int32?, table: [UCF.AnchorMangling: String]) {
            self.scope = scope
            self.table = table
        }
    }
}
extension SSGC.AnchorTable {
    subscript(normalizing fragment: String) -> Result<String, SSGC.AnchorResolutionError> {
        let id: UCF.AnchorMangling = .init(mangling: fragment)

        if  let fragment: String = self.table[id] {
            return .success(fragment)
        } else {
            var notes: [SSGC.AnchorResolutionError.Note] = self.table.map {
                .init(id: $0.key, fragment: $0.value)
            }

            notes.sort { $0.id < $1.id }

            return .failure(
                .init(
                    id: id,
                    fragment: fragment,
                    scope: scope,
                    notes: notes
                )
            )
        }
    }
}
