import Grammar

extension UCF.TypeElementRule
{
    enum PostfixMetatype:LiteralRule
    {
        typealias Location = String.Index
        static var literal:[Unicode.Scalar] { ["T","y","p","e"] }
    }
}
