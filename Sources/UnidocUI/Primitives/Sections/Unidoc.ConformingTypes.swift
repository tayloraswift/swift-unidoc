import HTML

extension Unidoc {
    struct ConformingTypes {
        let context: PeripheralPageContext

        private let culture: Unidoc.Scalar

        private var conformers: [Unidoc.ConformerGroup]
        private(set) var count: Int

        private init(_ context: PeripheralPageContext, culture: Unidoc.Scalar) {
            self.context = context
            self.culture = culture
            self.conformers = []
            self.count = 0
        }
    }
}
extension Unidoc.ConformingTypes {
    init(
        groups: [Unidoc.AnyGroup],
        bias culture: Unidoc.Scalar,
        with context: Unidoc.PeripheralPageContext
    ) throws {
        self.init(context, culture: culture)

        for group: Unidoc.AnyGroup in groups {
            guard case .conformer(let group) = group else {
                throw Unidoc.GroupTypeError.reject(group)
            }

            self.conformers.append(group)
            self.count += group.count
        }

        self.conformers.sort { $0.id < $1.id }
    }

    var cultures: Int { self.conformers.count }
}
extension Unidoc.ConformingTypes: HTML.OutputStreamable {
    static func += (html: inout HTML.ContentEncoder, self: Self) {
        for group: Unidoc.ConformerGroup in self.conformers {
            guard
            let culture: Unidoc.LinkReference<Unidoc.CultureVertex> = self.context[
                culture: group.culture
            ] else {
                continue
            }

            html[.section, { $0.class = "group conformer" }] {
                $0[.header] = Unidoc.ConformingTypesHeader.init(
                    heading: .init(culture: group.culture, bias: .culture(self.culture)),
                    culture: culture,
                    id: "se:\(culture.vertex.module.id)"
                )

                $0[.ul] {
                    $0.class = "cards dense"
                } = Unidoc.DenseList.init(
                    self.context,
                    members: (group.unconditional, group.conditional)
                )
            }
        }
    }
}
