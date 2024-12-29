extension UCF
{
    @frozen public
    struct Disambiguator:Equatable, Hashable, Sendable
    {
        public
        let conditions:[ConditionFilter]
        public
        let signature:SignatureFilter?

        @inlinable public
        init(conditions:[ConditionFilter], signature:SignatureFilter?)
        {
            self.conditions = conditions
            self.signature = signature
        }
    }
}
extension UCF.Disambiguator
{
    init?(
        signature:borrowing UCF.SignaturePattern?,
        clauses:borrowing [(String, String?)],
        source:borrowing Substring)
    {
        var conditions:[UCF.ConditionFilter] = []
            conditions.reserveCapacity(clauses.count)

        for clause:(String, String?) in copy clauses
        {
            //  The parser already collapses whitespace.
            guard
            let keywords:UCF.ConditionFilter.Keywords = .init(clause.0)
            else
            {
                return nil
            }

            let expected:Bool
            if  let value:String = clause.1
            {
                guard
                let value:Bool = .init(value)
                else
                {
                    return nil
                }

                expected = value
            }
            else
            {
                expected = true
            }

            conditions.append(.init(keywords: keywords, expected: expected))
        }

        //  If we got this far, the conditions (if any) were all valid and we can go ahead
        //  and extract the signature.
        self.init(
            conditions: conditions,
            signature: signature.map { .init(parsed: $0, source: source) })
    }
}
