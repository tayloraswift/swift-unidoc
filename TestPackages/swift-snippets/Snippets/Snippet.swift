enum E
{
    case a(Int)
}
extension E
{
    init()
    {
        let a = Int.init(1)
        self = .a(a)
    }
}

func f()
{
    let e = E()
    print(e)
}
