import UnidocRecords

extension Page.Docs.Zone.Deep
{
    struct Disambiguation
    {
        let matches:[Record.Master]

        init(matches:[Record.Master])
        {
            self.matches = matches
        }
    }
}
