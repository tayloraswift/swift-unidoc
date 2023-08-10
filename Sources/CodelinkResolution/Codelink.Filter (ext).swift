import Codelinks
import Unidoc

extension Codelink.Filter
{
    @inlinable public static
    func ~= (lhs:Self, rhs:Unidoc.Decl?) -> Bool
    {
        switch  (lhs, rhs)
        {
        case    (.actor,                .actor?),
                (.associatedtype,       .associatedtype?),
                (.case,                 .case?),
                (.class,                .class?),
                (.enum,                 .enum?),
                (.module,                nil),
                (.protocol,             .protocol?),
                (.struct,               .struct?),
                (.typealias,            .typealias?),
                (.typealias,            .actor?),
                (.typealias,            .class?),
                (.typealias,            .enum?),
                (.typealias,            .struct?):
            return true

        case    (.actor,                _),
                (.associatedtype,       _),
                (.case,                 _),
                (.class,                _),
                (.enum,                 _),
                (.module,               _?),
                (.macro,                _),
                (.protocol,             _),
                (.struct,               _),
                (.typealias,            _):
            return false

        case    (.subscript(let lhs),   .subscript(let rhs)?):
            return lhs ~= rhs

        case    (.func(let lhs),        .func(let rhs)?),
                (.var(let lhs),         .var(let rhs)?):
            return lhs ~= rhs

        case    (.subscript, _),
                (.func, _),
                (.var, _):
            return false
        }
    }
}
