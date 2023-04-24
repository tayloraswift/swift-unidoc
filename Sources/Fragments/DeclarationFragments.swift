public
struct DeclarationFragments<Symbol>:Hashable, Equatable where Symbol:Hashable
{
    @usableFromInline internal
    var fragments:[DeclarationFragment<Symbol, DeclarationOverlay>]

    @inlinable public
    init(fragments:[DeclarationFragment<Symbol, DeclarationOverlay>] = [])
    {
        self.fragments = fragments
    }
}
extension DeclarationFragments:Sendable where Symbol:Sendable
{
}

extension DeclarationFragments
{
    @inlinable public
    var identifiers:Identifiers { .init(self) }

    @inlinable public
    var abridged:Abridged { .init(self) }

    @inlinable public
    var expanded:Expanded { .init(self) }
}
extension DeclarationFragments:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.fragments.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.fragments.endIndex
    }
    @inlinable public
    subscript(index:Int) -> DeclarationFragment<Symbol, DeclarationOverlay>
    {
        self.fragments[index]
    }
}
extension DeclarationFragments
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

                    self.fragments.append(fragment.with(color: .init(
                        classification: fragment.color,
                        elision: elision)))
                    
                    continue matching
                }
                else
                {
                    self.fragments.append(fragment.with(color: .init(
                        classification: fragment.color,
                        elision: .abridged)))
                }
            }

            //  Ran out of fragments.
            self.fragments.append(current.with(color: .init(classification: current.color,
                elision: .expanded)))
        }
        while   let fragment:DeclarationFragment<Symbol, DeclarationFragmentClass?> =
                    expanded.next()
        {
            self.fragments.append(fragment.with(color: .init(classification: fragment.color,
                elision: .abridged)))
        }
    }
}
