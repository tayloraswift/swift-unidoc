extension Unidoc.User
{
    func card(
        tools:Unidoc.RulesPage.EditorTools) -> Unidoc.UserCard<Unidoc.RulesPage.EditorTools>
    {
        self.card(some: tools)
    }

    private
    func card<Tools>(some tools:Tools) -> Unidoc.UserCard<Tools>
    {
        .init(id: self.id,
            symbol: self.symbol ?? self.github?.login,
            icon: self.github?.icon,
            tools: tools)
    }
}
