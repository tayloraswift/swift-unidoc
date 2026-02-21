extension Markdown.BlockDirectiveOption {
    func `case`<Value>(
        _ value: Markdown.SourceString,
        of _: Value.Type = Value.self
    ) throws -> Value
        where Value: RawRepresentable<String> {
        guard
        let value: Value = .init(rawValue: value.string) else {
            throw Markdown.BlockDirectiveArgumentTypeError<Self, Value>.init(
                option: self,
                value: value.string
            )
        }

        return value
    }

    func cast<Value>(
        _ value: Markdown.SourceString,
        to _: Value.Type = Value.self
    ) throws -> Value
        where Value: LosslessStringConvertible {
        guard
        let value: Value = .init(value.string) else {
            throw Markdown.BlockDirectiveArgumentTypeError<Self, Value>.init(
                option: self,
                value: value.string
            )
        }

        return value
    }

    var duplicate: Markdown.BlockDirectiveDuplicateOptionError<Self> { .init(option: self) }
}
