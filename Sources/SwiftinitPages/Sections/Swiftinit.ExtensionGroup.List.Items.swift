extension Swiftinit.ExtensionGroup.List
{
    struct Items
    {
        private(set)
        var visible:[Swiftinit.DeclCard]
        private(set)
        var details:[Swiftinit.DeclCard]

        private
        init(visible:[Swiftinit.DeclCard], details:[Swiftinit.DeclCard])
        {
            self.visible = visible
            self.details = details
        }
    }
}
extension Swiftinit.ExtensionGroup.List.Items:ExpressibleByArrayLiteral
{
    init(arrayLiteral:Never...) { self.init(visible: [], details: []) }
}
extension Swiftinit.ExtensionGroup.List.Items
{
    var isEmpty:Bool
    {
        self.visible.isEmpty && self.details.isEmpty
    }

    mutating
    func append(_ card:Swiftinit.DeclCard?)
    {
        card.map { self.append($0) }
    }

    mutating
    func append(_ card:Swiftinit.DeclCard)
    {
        card.vertex.flags.route.underscored
        ? self.details.append(card)
        : self.visible.append(card)
    }
}
