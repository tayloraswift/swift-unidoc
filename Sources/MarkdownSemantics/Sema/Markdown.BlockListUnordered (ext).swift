extension Markdown.BlockListUnordered
{
    func promoteCards() -> [Markdown.BlockCard]?
    {
        var promoted:[Markdown.BlockCard] = []
        for item:Markdown.BlockItem in self.elements
        {
            if  let card:Markdown.BlockCard = .init(from: &item.elements)
            {
                promoted.append(card)
            }
        }
        return promoted.isEmpty ? nil : promoted
    }
}
