@frozen public enum InlineDictionary<Key, Value> where Key: Hashable {
    case one ((Key, Value))
    case some([Key: Value])
}
extension InlineDictionary: Sendable where Key: Sendable, Value: Sendable {
}
extension InlineDictionary: Equatable where Value: Equatable {
    @inlinable public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.one(let lhs), .one(let rhs)):    lhs == rhs
        case (.some(let lhs), .some(let rhs)):  lhs == rhs
        case _:                                 false
        }
    }
}
extension InlineDictionary: ExpressibleByDictionaryLiteral {
    @inlinable public init(dictionaryLiteral elements: (Key, Value)...) {
        if  elements.count == 1 {
            self = .one(elements[0])
        } else {
            self = .some(.init(uniqueKeysWithValues: elements))
        }
    }
}
extension InlineDictionary {
    @inlinable public subscript(key: Key, default value: @autoclosure () -> Value) -> Value {
        _read {
            switch self {
            case .one((key, let value)):    yield value
            case .one:                      yield value()
            case .some(let items):          yield items[key, default: value()]
            }
        }
        _modify {
            switch self {
            case .one((key, var value)):
                self = .some([:])
                defer { self = .one((key, value)) }
                yield &value

            case .one(let item):
                var value: Value = value()
                defer { self = .some([item.0: item.1, key: value]) }
                yield &value

            case .some(var items):
                self = .some([:])
                if  items.isEmpty {
                    var value: Value = value()
                    defer { self = .one((key, value)) }
                    yield &value
                } else {
                    defer { self = .some(items) }
                    yield &items[key, default: value()]
                }
            }
        }
    }
    @inlinable public subscript(_key key: Key) -> Value? {
        _read {
            switch self {
            case .one((key, let value)):    yield value
            case .one:                      yield nil
            case .some(let items):          yield items[key]
            }
        }
        _modify {
            switch self {
            case .one((key, let value)):
                self = .some([:])
                var value: Value? = value
                defer {
                    if  let value {
                        self = .one((key, value))
                    }
                }
                yield &value

            case .one(let item):
                var value: Value? = nil
                defer {
                    if  let value {
                        self = .some([item.0: item.1, key: value])
                    }
                }
                yield &value

            case .some(var items):
                self = .some([:])
                defer {
                    if  let item: (Key, Value) = items.first, items.count == 1 {
                        self = .one(item)
                    } else {
                        self = .some(items)
                    }
                }
                yield &items[key]
            }
        }
    }
}
