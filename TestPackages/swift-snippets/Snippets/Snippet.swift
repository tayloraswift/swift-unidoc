/// This is a caption with a codelink reference: ``CustomType``
///
/// Here is a reference to an out-of-package type: ``Int``
import Snippets

enum Enum
{
    case a(Int)
    case b(CustomType)
}
extension Enum
{
    init()
    {
        let a = Int.init(1)
        let b = CustomType.init()
        self = .a(a)
    }
}

struct `init`
{
    init()
    {
    }
}

func f()
{
    let _ = `init`()
    let _ = Enum()
    let _:Enum = Enum.init()
    let _:Enum = .init()
}
