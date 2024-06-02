extension Unidoc.User
{
    var card:Unidoc.UserCard
    {
        .init(id: self.id,
            symbol: self.symbol ?? self.github?.login,
            icon: self.github?.icon)
    }
}
