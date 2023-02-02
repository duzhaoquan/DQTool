//
//  File.swift
//  
//
//  Created by zhaoquan.du on 2023/2/2.
//

import Foundation

/// Decodable 解码时，如果model中的字段为非可选值而 json数据中没有该字段的key，就会解析失败。
/// 常用的方法是将数据模型中的key给成可选值类型，但是可选值类型在后续使用中比较麻烦需要解包。
/// 创建一种包装类型使其Decodable解码时如果解码失败那么就添加默认值，对于json中有可能不存在key的属性使用这种包装类型
/// 这样就不需要我们编写完全自定义的 Codable 实现，也省去了后续使用可选值的麻烦
public protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

public enum DecodableDefault {}

public extension DecodableDefault {
    @propertyWrapper
    struct Wrapper<Source: DecodableDefaultSource> {
        public typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue
        public init(wrappedValue: Value = Source.defaultValue) {
            self.wrappedValue = wrappedValue
        }
    }

    typealias Source = DecodableDefaultSource
    typealias List = Decodable & ExpressibleByArrayLiteral
    typealias Map = Decodable & ExpressibleByDictionaryLiteral

    //定义一些常用的数据类型默认值解码类型
    enum Sources {
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }

        public enum False: Source {
            public static var defaultValue: Bool { false }
        }
        
        public enum IntZero: Source {
            public static var defaultValue: Int { 0 }
        }
        
        public enum Int64Zero: Source {
            public static var defaultValue: Int64 { 0 }
        }
        
        public enum DoubleZero: Source {
            public static var defaultValue: Double { 0 }
        }
        
        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }

        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }

        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }
    }

    typealias IntZero = Wrapper<Sources.IntZero>
    typealias Int64Zero = Wrapper<Sources.Int64Zero>
    typealias DoubleZero = Wrapper<Sources.DoubleZero>
    typealias True = Wrapper<Sources.True>
    typealias False = Wrapper<Sources.False>
    typealias EmptyString = Wrapper<Sources.EmptyString>
    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension DecodableDefault.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

//MARK: 另一种方式
//定义常用类型的包装类型，自定义解码，此方式可以添加一些容错处理，如果json中key对应的类型不是model的类型但是可以转成model中的类型，也可以解码成功
@propertyWrapper
public struct DecodableString:Codable {
    public var wrappedValue: String
    
    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var string: String = ""
        do {
            string = try container.decode(String.self)
        } catch  {
            //此处可添加一些其它类型,例如Int
            do {
                string = String(try container.decode(Bool.self))
            } catch {
                do {
                    string = String(try container.decode(Double.self))
                } catch {
                    
                }
            }
        }
        self.wrappedValue = string
    }
}

@propertyWrapper
public struct DecodableInt:Codable {
    public var wrappedValue: Int
    
    public init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var num: Int = 0
        do {
            num = try container.decode(Int.self)
        } catch  {
            //此处可添加一些其它类型
            do {
                num = (try container.decode(Bool.self)) ? 1 : 0
            } catch {
                do {
                    num = Int(try container.decode(Double.self))
                } catch {
                    do {
                        num = Int(try container.decode(String.self)) ?? 0
                    } catch  {
                        
                    }
                    
                }
            }
        }
        self.wrappedValue = num
    }
}
@propertyWrapper
public struct DecodableDouble:Codable {
    public var wrappedValue: Double
    
    public init(wrappedValue: Double) {
        self.wrappedValue = wrappedValue
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var num: Double = 0
        do {
            num = try container.decode(Double.self)
        } catch  {
            //此处可添加一些其它类型
            do {
                num = Double(try container.decode(String.self)) ?? 0
            } catch {
                
            }
        }
        self.wrappedValue = num
    }
}
//使用
struct User:Codable {
    var name: String
    @DecodableInt var age: Int
    @DecodableDefault.EmptyString var nickName
}
