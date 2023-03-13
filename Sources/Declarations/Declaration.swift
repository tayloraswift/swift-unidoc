public
struct Declaration<Symbol>:Hashable, Equatable where Symbol:Hashable
{
    @usableFromInline internal
    var fragments:[DeclarationFragment<Symbol, DeclarationOverlay>]

    @inlinable public
    init(fragments:[DeclarationFragment<Symbol, DeclarationOverlay>] = [])
    {
        self.fragments = fragments
    }
}
extension Declaration:Sendable where Symbol:Sendable
{
}
extension Declaration
{
    @inlinable public
    init(
        expanded:__shared [DeclarationFragment<Symbol, DeclarationFragmentClass?>], 
        abridged:__shared [DeclarationFragment<Symbol, DeclarationFragmentClass?>])
    {
        self.init()

        var expanded:IndexingIterator<[DeclarationFragment<Symbol,
            DeclarationFragmentClass?>]> = expanded.makeIterator()
        
        matching:
        for current:DeclarationFragment<Symbol, DeclarationFragmentClass?> in abridged
        {
            while   let fragment:DeclarationFragment<Symbol, DeclarationFragmentClass?> =
                        expanded.next()
            {
                if  fragment == current
                {
                    let elision:DeclarationFragmentElision?

                    switch (fragment.color, fragment.spelling)
                    {
                    case    (.label?, _),
                            (.identifier?, _), 
                            (.keyword?, "init"),
                            (.keyword?, "deinit"),
                            (.keyword?, "subscript"):
                        elision = .never
                    
                    case _:
                        elision = nil
                    }

                    self.append(fragment, with: .init(
                        classification: fragment.color,
                        elision: elision))
                    
                    continue matching
                }
                else
                {
                    self.append(fragment, with: .init(
                        classification: fragment.color,
                        elision: .abridged))
                }
            }

            //  Ran out of fragments.
            self.append(current, with: .init(classification: current.color,
                elision: .expanded))
        }
        while   let fragment:DeclarationFragment<Symbol, DeclarationFragmentClass?> =
                    expanded.next()
        {
            self.append(fragment, with: .init(classification: fragment.color,
                elision: .abridged))
        }
    }

    @inlinable internal mutating
    func append(_ fragment:DeclarationFragment<Symbol, some Hashable>,
        with overlay:DeclarationOverlay)
    {
        self.fragments.append(.init(fragment.spelling,
            symbol: fragment.symbol,
            color: overlay))
    }
}
