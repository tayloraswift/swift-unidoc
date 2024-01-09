import HTML

extension Swiftinit
{
    struct ConformingTypes
    {
        let context:IdentifiablePageContext<Swiftinit.SecondaryOnly>

        private
        var conformers:[Unidoc.ConformerGroup]

        private
        let bias:Bias

        private
        init(_ context:IdentifiablePageContext<Swiftinit.SecondaryOnly>,
            conformers:[Unidoc.ConformerGroup] = [],
            bias:Bias)
        {
            self.context = context
            self.conformers = conformers
            self.bias = bias
        }
    }
}
extension Swiftinit.ConformingTypes
{
    init(_ context:IdentifiablePageContext<Swiftinit.SecondaryOnly>,
        organizing groups:consuming [Unidoc.AnyGroup],
        bias:Swiftinit.Bias) throws
    {
        self.init(consume context, bias: bias)

        for group:Unidoc.AnyGroup in groups
        {
            guard case .conformer(let group) = group
            else
            {
                throw Unidoc.GroupTypeError.reject(group)
            }

            self.conformers.append(group)
        }

        self.conformers.sort { $0.id < $1.id }
    }
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
                    heading: .init(culture: group.culture, bias: self.bias))

                $0[.ul] = Swiftinit.DenseList.init(self.context,
                    members: (group.unconditional, group.conditional))
            }
        }
    }
}
