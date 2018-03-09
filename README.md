![](http://og1yl0w9z.bkt.clouddn.com/18-3-9/45811958.jpg)

[EN](#Requirements) | [中文](#中文说明)

# Swift 4.0 NewFeature

DemoSwift 4.0 New Feature Summary Demo

### First, Key Paths new syntax

The key-path is usually used in Key-Value Coding (KVC) and Key-Value Watch (KVO). The relevant contents of KVC and KVO can refer to the article I wrote earlier: Swift - Introduction and usage examples of Reflection (With KVC introduction)

1.Previously used Swift3 is a String type key-Path
```
// User class
class User: NSObject{
    @objc var name:String = ""  // name
    @objc var age:Int = 0  // age
}
 
// Create a User instance object
let user1 = User()
user1.name = "hangge"
user1.age = 100
 
// Use KVC values
let name = user1.value(forKey: "name")
print(name)
 
// Use KVC assignment
user1.setValue("hangge.com", forKey: "name")
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/51120116.jpg)

2.Added the #keyPath() method to Swift3
Use the #keyPath() method to avoid problems caused by misspellings.
```
// User Class
class User: NSObject{
    @objc var name:String = ""  // name
    @objc var age:Int = 0  // age
}
 
// Create a User instance object
let user1 = User()
user1.name = "hangge"
user1.age = 100
 
// Use KVC values
let name = user1.value(forKeyPath: #keyPath(User.name))
print(name)
 
// Use KVC values
user1.setValue("hangge.com", forKeyPath: #keyPath(User.name))
```
3. Creating KeyPath directly from \ in Swift4
The new approach is not only simpler to use but also has the following advantages:
* Type can be defined as class, struct
* Do not add keywords such as @objc when defining the type
* Better performance
* Type safety and type inference, for example: user1.value(forKeyPath: #keyPath(User.name)) The returned type is Any, user1[keyPath: \User.name] directly returns a String type.
* Can be used on all value types
(1) For example, the above example can be written in Swift4:
```
// Class Name
class User: NSObject{
    var name:String = ""  //name
    var age:Int = 0  //age
}
 
// Create a User instance object
let user1 = User()
user1.name = "hangge"
user1.age = 100
 
// Use KVC values
let name = user1[keyPath: \User.name]
print(name)
 
// Use KVC values
user1[keyPath: \User.name] = "hangge.com"
```

(2) It is also possible that the keyPath is defined outside:

```
let keyPath = \User.name
 
let name = user1[keyPath: keyPath]
print(name)
 
user1[keyPath: keyPath] = "hangge.com"
```

(3) You can use the appending method to add a new Key Path based on the defined Key Path.

```
let keyPath1 = \User.phone
let keyPath2 = keyPath1.appending(path: \.number)
```

----
### Second, the combination of types and protocols

In Swift4, classes and protocols can be grouped together using a & as a type.

Use Example 1:
```
protocol MyProtocol { }
 
class View { }
 
class ViewSubclass: View, MyProtocol { }
 
class MyClass {
    var delegate: (View & MyProtocol)?
}
 
let myClass = MyClass()
myClass.delegate = ViewSubclass() // This compilation is normal
myClass.delegate = View() // This compilation error:
```
The specific error message is as follows:

![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/54150241.jpg)

Use Example 2:
```
protocol Shakeable {
    func shake()
}
 
extension UIButton: Shakeable {
    func shake() {
        /* ... */
    }
}
 
extension UISlider: Shakeable {
    func shake() {
        /* ... */
    }
}
 
func shakeEm(controls: [UIControl & Shakeable]) {
    for control in controls where control.isEnabled {
        control.shake()
    }
}
```

----
### Three, subscript support generics
1. Subscript's return type supports generics
Sometimes we write some data containers. Swift supports reading and writing data in containers through subscripts. However, if the data type in the container class is defined as generic, the past subscript syntax can only return Any, and after using the value of as? Now that Swift4 defines subscripts, you can also use generics.

```
struct GenericDictionary<Key: Hashable, Value> {
    private var data: [Key: Value]
     
    init(data: [Key: Value]) {
        self.data = data
    }
     
    subscript<T>(key: Key) -> T? {
        return data[key] as? T
    }
}
 
// Dictionary type: [String: Any]
let earthData = GenericDictionary(data: ["name": "Earth", "population": 7500000000, "moons": 1])
 
// Automatic conversion type, no need to write "as? String"
let name: String? = earthData["name"]
print(name)
 
// Automatic conversion type, no need to write "as? Int"
let population: Int? = earthData["population"]
print(population)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/10260751.jpg)

2. Subscript types also support generics
```
extension GenericDictionary {
    subscript<Keys: Sequence>(keys: Keys) -> [Value] where Keys.Iterator.Element == Key {
        var values: [Value] = []
        for key in keys {
            if let value = data[key] {
                values.append(value)
            }
        }
        return values
    }
}
 
// Array index
let nameAndMoons = earthData[["moons", "name"]]        // [1, "Earth"]
// Set index
let nameAndMoons2 = earthData[Set(["moons", "name"])]  // [1, "Earth"]
```
----
### Codable serialization

If you want to persist an object, you need to serialize the object. The past practice was to implement the NSCoding protocol, but the code to implement the NSCoding protocol was cumbersome to write, especially when there were many attributes.
The Codable protocol was introduced in Swift4, which can greatly reduce our workload. We only need to make the serialized object conform to the Codable protocol, without writing any other code.

```
struct Language: Codable {
    var name: String
    var version: Int
}
```

1.Encode operation
We can encode objects that conform to the Codable protocol directly into JSON or PropertyList.

```
let swift = Language(name: "Swift", version: 4)
 
// Encoded object
let encodedData = try JSONEncoder().encode(swift)
 
// Get a String from the encoded object
let jsonString = String(data: encodedData, encoding: .utf8)
print(jsonString)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/81600262.jpg)

2.Decode operation

```
let decodedData = try JSONDecoder().decode(Language.self, from: encodedData)
print(decodedData.name, decodedData.version)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/80877317.jpg)

----
### Subtring
One of the big changes in Swift 4 is that Strings can be used as Collections, not because Strings implement the Collection protocol, but String itself adds a lot of methods in the Collection protocol, making Strings look like Collections when used.
```
let str = "hangge.com"
 
print(str.prefix(5)) // "hangg"
print(str.suffix(5)) // "e.com"
 
print(str.dropFirst()) // "angge.com"
print(str.dropLast()) // "hangge.co"
```

For example, in the above example, we use some methods of the Collection protocol to intercept strings, but their return result is not a String type, but a new Substring type in Swift4.

1. Why introduce Substring?
Since all we want is a string, it would be nice to just return a String. Why do we have to return Substring more than once? There is only one reason: performance. Specifically refer to the following figure:
When we use some Collection methods to get part of a String, we create Substrings. Substring shares a Storage with the original String. This means that when we operate this section, we do not need to create memory frequently, which makes Swift 4 String-related operations to achieve higher performance.
When we explicitly convert a Substring to a String , we will copy a String to the new memory space. At this point, the new String is not related to the previous String.

2. Considerations for using Substring
Since Substring and the original String are shared storage space, as long as we use Substring, the original String will exist in the memory space. The entire String is released only after Substring is released.
And the Substring type can't be assigned directly to the place where the String type is needed. We must use String() to wrap a layer. Of course, the system will create a new string object by copying, and then the original string will be released.

3. Use the sample
This extends String and adds a subString method. You can directly truncate substrings based on the starting position (Int type) and the required length (Int type).

```
extension String {
    // Choosing a string based on start position and length
    func subString(start:Int, length:Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        return String(self[st ..< en])
    }
}
```

Use the sample:

```
let str1 = "欢迎访问hangge.com"
let str2 = str1.subString(start: 4, length: 6)
print("原字符串：\(str1)")
print("截取出的字符串：\(str2)")
```

The operating results are as follows:

![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/34732691.jpg)

Note: At the end of this method we will explicitly convert Substring to String and return.

----
### Cancel the swap method

(1) In the past we used swap(: :) to swap the values of two variables:
```
var a = 1
var b = 2
swap(&a, &b)
print(a, b)
```
(2) The latter swap() method will be deprecated. It is recommended to use the tuple feature to implement the value exchange. It also requires only one sentence to be implemented:
```
var a = 1
var b = 2
(b, a) = (a, b)
print(a, b)
```
The advantage of using the tuple approach is that multiple variable values can also be exchanged together:
```
var a = 1
var b = 2
var c = 3
(a, b, c) = (b, c, a)
print(a, b, c)
```
(3) Add: Now that the array has added a swapAt method, you can swap the two elements.
```
var fruits = ["apple", "pear", "grape", "banana"]
// Exchanging element positions (exchanging the 2nd and 3rd element positions)
fruits.swapAt(1, 2)
print(fruits)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/27210545.jpg)

----
### Reduce the implicit @objc automatic inference

1. Past (Swift3)
(1) If you want to expose the API written in Swift to Objective-C calls, you need to increase @objc. In Swift 3, the compiler implicitly adds @objc to us in many places.
(2) For example, when a class inherits from NSObject, all methods of this class are implicitly added with @objc.

```
class MyClass: NSObject {
    func print() { } // Include implicit @objc
    func show() { } // Include implicit @objc
}
```
(3) But many of them do not need to be exposed to Objective-C and @objc is added. A large number of @objc will cause the size of the binary file to increase.

2. The current situation (Swift4)
(1) Implicit @objc auto-inference in Swift 4 will only happen if the @objc must be used:
* Overriding the Objective-C method of the parent class
* Meets an Objective-C agreement

(2) Most places must be manually displayed with @objc.
```
class MyClass: NSObject {
    @objc func print() { } // Shows with @objc
    @objc func show() { } // Shows with @objc
```
(3) If @objcMembers is added before the class, then it, its subclasses, and the methods in the extension will implicitly add @objc.
```
@objcMembers
class MyClass: NSObject {
    func print() { } // Include implicit @objc
    func show() { } // Include implicit @objc
}
 
extension MyClass {
    func baz() { } // Include implicit @objc
}
```
(4) If @objc is added before the extension, the method in the extension implicitly adds @objc.
```
class SwiftClass { }
 
@objc extension SwiftClass {
    func foo() { } // Include implicit @objc
    func bar() { } // Include implicit @objc
}
```
(5) If @nonobjc is added before the extension, the methods in this extension will not implicitly add @objc.
```
@objcMembers
class MyClass : NSObject {
    func wibble() { } // Include implicit @objc
}
 
@nonobjc extension MyClass {
    func wobble() { } // Does not contain implicit @objc
}
```

---
# 中文说明

Swift 4.0 新特征汇总演示 Demo

### 一、Key Paths 新语法
key-path 通常是用在键值编码（KVC）与键值观察（KVO）上的，KVC、KVO 相关内容可以参考我之前写的这篇文章：Swift - 反射（Reflection）的介绍与使用样例（附KVC介绍）

1.Swift3 之前使用的是 String 类型的 key-Path
```
//用户类
class User: NSObject{
    @objc var name:String = ""  //姓名
    @objc var age:Int = 0  //年龄
}
 
//创建一个User实例对象
let user1 = User()
user1.name = "hangge"
user1.age = 100
 
//使用KVC取值
let name = user1.value(forKey: "name")
print(name)
 
//使用KVC赋值
user1.setValue("hangge.com", forKey: "name")
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/51120116.jpg)

2.到了 Swift3 新增了 #keyPath() 写法
使用 #keyPath() 写法，可以避免我们因为拼写错误而引发问题。
```
//用户类
class User: NSObject{
    @objc var name:String = ""  //姓名
    @objc var age:Int = 0  //年龄
}
 
//创建一个User实例对象
let user1 = User()
user1.name = "hangge"
user1.age = 100
 
//使用KVC取值
let name = user1.value(forKeyPath: #keyPath(User.name))
print(name)
 
//使用KVC赋值
user1.setValue("hangge.com", forKeyPath: #keyPath(User.name))
```
3.Swift4 中直接用 \ 作为开头创建 KeyPath
新的方式不仅使用更加简单，而且有如下优点：
* 类型可以定义为 class、struct
* 定义类型时无需加上 @objc 等关键字
* 性能更好
* 类型安全和类型推断，例如：user1.value(forKeyPath: #keyPath(User.name)) 返回的类型是 Any，user1[keyPath: \User.name] 直接返回 String 类型
* 可以在所有值类型上使用
（1）比如上面的样例在 Swift4 中可以这么写：
```
//用户类
class User: NSObject{
    var name:String = ""  //姓名
    var age:Int = 0  //年龄
}
 
//创建一个User实例对象
let user1 = User()
user1.name = "hangge"
user1.age = 100
 
//使用KVC取值
let name = user1[keyPath: \User.name]
print(name)
 
//使用KVC赋值
user1[keyPath: \User.name] = "hangge.com"
```
（2）keyPath 定义在外面也是可以的：
```
let keyPath = \User.name
 
let name = user1[keyPath: keyPath]
print(name)
 
user1[keyPath: keyPath] = "hangge.com"
```
（3）可以使用 appending 方法向已定义的 Key Path 基础上填加新的 Key Path。
```
let keyPath1 = \User.phone
let keyPath2 = keyPath1.appending(path: \.number)
```
----
### 二、类与协议的组合类型

在 Swift4 中，可以把类（Class）和协议（Protocol）用 & 组合在一起作为一个类型使用。

使用样例1：
```
protocol MyProtocol { }
 
class View { }
 
class ViewSubclass: View, MyProtocol { }
 
class MyClass {
    var delegate: (View & MyProtocol)?
}
 
let myClass = MyClass()
myClass.delegate = ViewSubclass() //这个编译正常
myClass.delegate = View() //这个编译报错:
```
具体错误信息如下：

![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/54150241.jpg)

使用样例2：
```
protocol Shakeable {
    func shake()
}
 
extension UIButton: Shakeable {
    func shake() {
        /* ... */
    }
}
 
extension UISlider: Shakeable {
    func shake() {
        /* ... */
    }
}
 
func shakeEm(controls: [UIControl & Shakeable]) {
    for control in controls where control.isEnabled {
        control.shake()
    }
}
```
----
### 三、下标支持泛型
1.下标的返回类型支持泛型
有时候我们会写一些数据容器，Swift 支持通过下标来读写容器中的数据。但是如果容器类中的数据类型定义为泛型，过去下标语法就只能返回 Any，在取出值后需要用 as? 来转换类型。现在 Swift4 定义下标也可以使用泛型了。
```
struct GenericDictionary<Key: Hashable, Value> {
    private var data: [Key: Value]
     
    init(data: [Key: Value]) {
        self.data = data
    }
     
    subscript<T>(key: Key) -> T? {
        return data[key] as? T
    }
}
 
//字典类型: [String: Any]
let earthData = GenericDictionary(data: ["name": "Earth", "population": 7500000000, "moons": 1])
 
//自动转换类型，不需要在写 "as? String"
let name: String? = earthData["name"]
print(name)
 
//自动转换类型，不需要在写 "as? Int"
let population: Int? = earthData["population"]
print(population)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/10260751.jpg)

2.下标类型同样支持泛型
```
extension GenericDictionary {
    subscript<Keys: Sequence>(keys: Keys) -> [Value] where Keys.Iterator.Element == Key {
        var values: [Value] = []
        for key in keys {
            if let value = data[key] {
                values.append(value)
            }
        }
        return values
    }
}
 
// Array下标
let nameAndMoons = earthData[["moons", "name"]]        // [1, "Earth"]
// Set下标
let nameAndMoons2 = earthData[Set(["moons", "name"])]  // [1, "Earth"]
```
----
### 四、Codable 序列化

如果要将一个对象持久化，需要把这个对象序列化。过去的做法是实现 NSCoding 协议，但实现 NSCoding 协议的代码写起来很繁琐，尤其是当属性非常多的时候。
Swift4 中引入了 Codable 协议，可以大大减轻了我们的工作量。我们只需要让需要序列化的对象符合 Codable 协议即可，不用再写任何其他的代码。
```
struct Language: Codable {
    var name: String
    var version: Int
}
```
1.Encode 操作
我们可以直接把符合了 Codable 协议的对象 encode 成 JSON 或者 PropertyList。
```
let swift = Language(name: "Swift", version: 4)
 
//encoded对象
let encodedData = try JSONEncoder().encode(swift)
 
//从encoded对象获取String
let jsonString = String(data: encodedData, encoding: .utf8)
print(jsonString)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/81600262.jpg)

2.Decode 操作
```
let decodedData = try JSONDecoder().decode(Language.self, from: encodedData)
print(decodedData.name, decodedData.version)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/80877317.jpg)

----
### 五、Subtring
Swift 4 中有一个很大的变化就是 String 可以当做 Collection 来用，并不是因为 String 实现了 Collection 协议，而是 String 本身增加了很多 Collection 协议中的方法，使得 String 在使用时看上去就是个 Collection。
```
let str = "hangge.com"
 
print(str.prefix(5)) // "hangg"
print(str.suffix(5)) // "e.com"
 
print(str.dropFirst()) // "angge.com"
print(str.dropLast()) // "hangge.co"
```
比如上面的样例，我们使用一些 Collection 协议的方法对字符串进行截取，只不过它们的返回结果不是 String 类型，而是 Swift4 新增的 Substring 类型。

1.为何要引入 Substring？
既然我们想要的到的就是字符串，那么直接返回 String 就好了，为什么还要多此一举返回 Substring。原因只有一个：性能。具体可以参考下图：
当我们用一些 Collection 的方式得到 String 里的一部分时，创建的都是 Substring。Substring 与原 String 是共享一个 Storage。这意味我们在操作这个部分的时候，是不需要频繁的去创建内存，从而使得 Swift 4 的 String 相关操作可以获取比较高的性能。
而当我们显式地将 Substring 转成 String 的时候，才会 Copy 一份 String 到新的内存空间来，这时新的 String 和之前的 String 就没有关系了。

2.使用 Substring 的注意事项
由于 Substring 与原 String 是共享存储空间的，只要我们使用了 Substring，原 String 就会存在内存空间中。只有 Substring 被释放以后，整个 String 才会被释放。
而且 Substring 类型无法直接赋值给需要 String 类型的地方，我们必须用 String() 包一层。当然这时系统就会通过复制创建出一个新的字符串对象，之后原字符串就会被释放。

3.使用样例
这里对 String 进行扩展，新增一个 subString 方法。直接可以根据起始位置（Int 类型）和需要的长度（Int 类型），来截取出子字符串。
```
extension String {
    //根据开始位置和长度截取字符串
    func subString(start:Int, length:Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        return String(self[st ..< en])
    }
}
```
使用样例：
```
let str1 = "欢迎访问hangge.com"
let str2 = str1.subString(start: 4, length: 6)
print("原字符串：\(str1)")
print("截取出的字符串：\(str2)")
```
运行结果如下：

![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/34732691.jpg)

注意：这个方法最后我们会将 Substring 显式地转成 String 再返回。

----
### 六、废除 swap 方法

（1）过去我们会使用 swap(_:_:) 来将两个变量的值进行交换：
```
var a = 1
var b = 2
swap(&a, &b)
print(a, b)
```
（2）后面 swap() 方法将会被废弃，建议使用 tuple（元组）特性来实现值交换，也只需要一句话就能实现：
```
var a = 1
var b = 2
(b, a) = (a, b)
print(a, b)
```
使用 tuple 方式的好处是，多个变量值也可以一起进行交换：
```
var a = 1
var b = 2
var c = 3
(a, b, c) = (b, c, a)
print(a, b, c)
```
（3）补充一下：现在数组增加了个 swapAt 方法可以实现两个元素的位置交换。
```
var fruits = ["apple", "pear", "grape", "banana"]
//交换元素位置（第2个和第3个元素位置进行交换）
fruits.swapAt(1, 2)
print(fruits)
```
![](http://og1yl0w9z.bkt.clouddn.com/18-1-5/27210545.jpg)

----
### 七、减少隐式 @objc 自动推断

1.过去的情况（Swift3）
（1）在项目中如果想把 Swift 写的 API 暴露给 Objective-C 调用，需要增加 @objc。在 Swift 3 中，编译器会在很多地方为我们隐式的加上 @objc。
（2）比如当一个类继承于 NSObject，那么这个类的所有方法都会被隐式的加上 @objc。
```
class MyClass: NSObject {
    func print() { } // 包含隐式的 @objc
    func show() { } // 包含隐式的 @objc
}
```
（3）但这样做很多并不需要暴露给 Objective-C 也被加上了 @objc。而大量 @objc 会导致二进制文件大小的增加。

2.现在的情况（Swift4）
（1）在 Swift 4 中隐式 @objc 自动推断只会发生在下面这种必须要使用 @objc 的情况：
* 覆盖父类的 Objective-C 方法
* 符合一个 Objective-C 的协议

（2）大多数地方必须手工显示地加上 @objc。
```
class MyClass: NSObject {
    @objc func print() { } //显示的加上 @objc
    @objc func show() { } //显示的加上 @objc
}
```
（3）如果在类前加上 @objcMembers，那么它、它的子类、扩展里的方法都会隐式的加上 @objc。
```
@objcMembers
class MyClass: NSObject {
    func print() { } //包含隐式的 @objc
    func show() { } //包含隐式的 @objc
}
 
extension MyClass {
    func baz() { } //包含隐式的 @objc
}
```
（4）如果在扩展（extension）前加上 @objc，那么该扩展里的方法都会隐式的加上 @objc。
```
class SwiftClass { }
 
@objc extension SwiftClass {
    func foo() { } //包含隐式的 @objc
    func bar() { } //包含隐式的 @objc
}
```
（5）如果在扩展（extension）前加上 @nonobjc，那么该扩展里的方法都不会隐式的加上 @objc。
```
@objcMembers
class MyClass : NSObject {
    func wibble() { } //包含隐式的 @objc
}
 
@nonobjc extension MyClass {
    func wobble() { } //不会包含隐式的 @objc
}
```

