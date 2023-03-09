/// Swift typealiases can have overloads across different generic contexts.
/// Typealiases are the only phylum of type that can have overloads.
///
/// We currently cannot have more than one declaration of a struct, enum,
/// etc, even with different generic constraints on the outer type.
///
/// Protocols can never appear inside other types, so they can never have
/// overloads either.
public
enum OverloadedTypealiases<T>
{
}

extension OverloadedTypealiases where T == Int
{
    public
    typealias Inner = Character
}
extension OverloadedTypealiases where T == Double
{
    public
    typealias Inner = String
}
