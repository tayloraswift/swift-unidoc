import UCF 

extension UCF
{
    struct Predicate
    {
        let suffix:Selector.Suffix?
        let seal:Selector.Seal?

        init(suffix:Selector.Suffix?, seal:Selector.Seal?)
        {
            self.suffix = suffix
            self.seal = seal
        }
    }
}
