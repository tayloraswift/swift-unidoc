import UCF 

extension UCF
{
    struct Predicate
    {
        let suffix:Selector.Suffix?
        let hasEmptyTrailingParentheses:Bool

        init(suffix:Selector.Suffix?, hasEmptyTrailingParentheses:Bool)
        {
            self.suffix = suffix
            self.hasEmptyTrailingParentheses = hasEmptyTrailingParentheses
        }
    }
}
