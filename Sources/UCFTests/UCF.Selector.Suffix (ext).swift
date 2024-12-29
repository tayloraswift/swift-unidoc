import UCF

extension UCF.Selector.Suffix
{
    static func keywords(_ keywords:UCF.ConditionFilter.Keywords) -> Self
    {
        .unidoc(.init(conditions: [.init(keywords: keywords, expected: true)], signature: nil))
    }
    static func signature(_ signature:UCF.SignatureFilter) -> Self
    {
        .unidoc(.init(conditions: [], signature: signature))
    }
}
