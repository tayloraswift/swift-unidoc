extension Unidoc.User
{
    /// GitHub discourages us from trying to predict the user’s avatar URL. However, the
    /// URL they provide us by default serves an image that is far too large for our
    /// purposes. We can modify the URL to request a smaller image, but at that point we
    /// might as well just compute the whole URL ourselves.
    func icon(size:Int) -> String?
    {
        self.id.github.map { "https://avatars.githubusercontent.com/u/\($0)?s=\(size)" }
    }

    func card(
        tools:Unidoc.RulesPage.EditorTools) -> Unidoc.UserCard<Unidoc.RulesPage.EditorTools>
    {
        self.card(some: tools)
    }

    func card<Tools>(some tools:Tools?) -> Unidoc.UserCard<Tools>
    {
        .init(id: self.id,
            symbol: self.symbol ?? self.github?.login,
            icon: self.icon(size: 64),
            tools: tools)
    }
}
