extension Tabulator
{
    struct Library
    {
        let extensions:Extensions
        let party:Party

        init(extensions:Extensions, party:Party)
        {
            self.extensions = extensions
            self.party = party
        }
    }
}
