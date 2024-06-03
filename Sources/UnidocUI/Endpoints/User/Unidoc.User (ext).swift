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
        let icon:String?
        //  GitHub discourages us from trying to predict the user’s avatar URL. However, the
        //  URL they provide us by default serves an image that is far too large for our
        //  purposes. We can modify the URL to request a smaller image, but at that point we
        //  might as well just compute the whole URL ourselves.
        if  let id:UInt32 = self.id.github
        {
            icon = "https://avatars.githubusercontent.com/u/\(id)?s=64"
        }
        else
        {
            icon = nil
        }

        return .init(id: self.id,
            symbol: self.symbol ?? self.github?.login,
            icon: icon,
            tools: tools)
    }
}
