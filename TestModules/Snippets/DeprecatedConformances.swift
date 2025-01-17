public
protocol P {}

extension P
{
    public
    func f() {}
}

public
struct S {}

@available(*, deprecated)
extension S:P
{
}
@available(*, deprecated)
extension S
{
    public
    func g() {}
}
