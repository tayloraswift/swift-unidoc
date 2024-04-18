import HTML

extension Swiftinit
{
    struct ConformingTypes
    {
        let context:Unidoc.PeripheralPageContext

        private
        let culture:Unidoc.Scalar

        private
        var conformers:[Unidoc.ConformerGroup]
        private(set)
        var count:Int

        private
        init(_ context:Unidoc.PeripheralPageContext, culture:Unidoc.Scalar)
        {
            self.context = context
            self.culture = culture
            self.conformers = []
            self.count = 0
        }
    }
}
extension Swiftinit.ConformingTypes
{
    init(_ context:Unidoc.PeripheralPageContext,
        groups:[Unidoc.AnyGroup],
        bias culture:Unidoc.Scalar) throws
    {
        self.init(context, culture: culture)

        for group:Unidoc.AnyGroup in groups
        {
            guard case .conformer(let group) = group
            else
            {
                throw Unidoc.GroupTypeError.reject(group)
            }

            self.conformers.append(group)
            self.count += group.count
        }

        self.conformers.sort { $0.id < $1.id }
    }

    var cultures:Int { self.conformers.count }
}
extension Swiftinit.ConformingTypes:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for group:Unidoc.ConformerGroup in self.conformers
        {
            html[.section, { $0.class = "group conformer" }]
            {
                $0[.h2] = Swiftinit.ConformingTypesHeader.init(self.context,
                    heading: .init(culture: group.culture, bias: .culture(self.culture)))

                $0[.ul]
                {
                    $0.class = "cards dense"
                } = Swiftinit.DenseList.init(self.context,
                    members: (group.unconditional, group.conditional))
            }
        }
    }
}
