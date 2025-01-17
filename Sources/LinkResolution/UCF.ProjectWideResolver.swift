import FNV1
import InlineArray
import UCF

extension UCF
{
    @frozen public
    struct ProjectWideResolver
    {
        @usableFromInline
        let scope:ResolutionScope

        @usableFromInline
        let global:ResolutionTable<PackageOverload>
        @usableFromInline
        let causal:ResolutionTable<CausalOverload>?

        @inlinable public
        init(scope:ResolutionScope,
            global:ResolutionTable<PackageOverload>,
            causal:ResolutionTable<CausalOverload>? = nil)
        {
            self.global = global
            self.causal = causal
            self.scope = scope
        }
    }
}
extension UCF.ProjectWideResolver
{
    public
    func resolve(_ selector:UCF.Selector) throws -> UCF.Resolution<any UCF.ResolvableOverload>
    {
        let predicate:UCF.Predicate = try .init(from: selector)
        var rejected:[FNV24: any UCF.ResolvableOverload]

        if  let causal:UCF.ResolutionTable<UCF.CausalOverload> = self.causal
        {
            switch causal.resolve(matching: predicate,
                base: selector.base,
                path: selector.path,
                in: self.scope)
            {
            case .module(let module):
                return .module(module)

            case .overload(let overload):
                return .overload(overload)

            case .ambiguous(let overloads, rejected: let rejections):
                rejected = rejections.reduce(into: [:]) { $0[$1.traits.hash] = $1 }

                guard overloads.isEmpty
                else
                {
                    return .ambiguous(overloads, rejected: [_].init(rejected.values))
                }
            }
        }
        else
        {
            rejected = [:]
        }

        switch self.global.resolve(matching: predicate,
            base: selector.base,
            path: selector.path,
            in: self.scope)
        {
        case .module(let module):
            return .module(module)

        case .overload(let overload):
            return .overload(overload)

        case .ambiguous(let overloads, rejected: let rejections):
            for overload:any UCF.ResolvableOverload in rejections
            {
                rejected[overload.traits.hash] = overload
            }

            return .ambiguous(overloads, rejected: [_].init(rejected.values))
        }
    }
}
