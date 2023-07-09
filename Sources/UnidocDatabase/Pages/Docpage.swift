import UnidocRecords

@frozen public
struct Docpage:Equatable, Sendable
{
    public
    let principal:Principal
    public
    let entourage:[Record.Master]

    @inlinable public
    init(principal:Principal, entourage:[Record.Master])
    {
        self.principal = principal
        self.entourage = entourage
    }
}
