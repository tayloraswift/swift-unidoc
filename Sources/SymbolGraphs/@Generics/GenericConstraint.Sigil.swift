import Generics

extension GenericConstraint
{
    @frozen public
    enum Sigil:Unicode.Scalar
    {
        case conformer  = "0"
        case subclass   = "1"
        case type       = "2"
    }
}
