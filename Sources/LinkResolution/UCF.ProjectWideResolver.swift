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
    func resolve(_ selector:UCF.Selector) -> UCF.Resolution<any UCF.ResolvableOverload>
    {
        var rejected:[any UCF.ResolvableOverload]

        if  let causal:UCF.ResolutionTable<UCF.CausalOverload> = self.causal
        {
            switch causal.resolve(selector, in: self.scope)
            {
            case .module(let module):
                return .module(module)

            case .overload(let overload):
                return .overload(overload)

            case .ambiguous(let overloads, rejected: let rejections):
                rejected = rejections

                guard overloads.isEmpty
                else
                {
                    return .ambiguous(overloads, rejected: rejected)
                }
            }
        }
        else
        {
            rejected = []
        }

        switch self.global.resolve(selector, in: self.scope)
        {
        case .module(let module):
            return .module(module)

        case .overload(let overload):
            return .overload(overload)

        case .ambiguous(let overloads, rejected: let rejections):
            rejected += rejections

            return .ambiguous(overloads, rejected: rejected)
        }
    }
}
