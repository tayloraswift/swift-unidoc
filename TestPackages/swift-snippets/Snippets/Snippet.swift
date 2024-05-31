enum Enum
{
    case a(Int)
}
extension Enum
{
    init()
    {
        let a = Int.init(1)
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
