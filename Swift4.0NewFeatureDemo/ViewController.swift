//
//  ViewController.swift
//  Swift4.0NewFeatureDemo
//
//  Created by WhatsXie on 2018/1/5.
//  Copyright © 2018年 R.S. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Xcode 使用示例
        testUseingDemo()
    }
    
    func testUseingDemo() {
        // 图片使用方法 Image Literal
        let image = #imageLiteral(resourceName: "trans_alipay")
        let imageName = #imageLiteral(resourceName: "trans_wx")

        // 颜色使用方法 Color Literal
        let color = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)

        // 参数注释方法 command+option+/
        print(addFunc(intA: 2, intB: 2))
        
        //        swift4_func1()
        
        //        swift4_func2()
        
        //        swift4_func4()
        
        //        swift4_func5_EncodeAndDecode()
        
        //        swift4_func6()
        
        swift4_func7()
    }
    
    /// int A + B
    ///
    /// - Parameters:
    ///   - intA: int A
    ///   - intB: int B
    /// - Returns: int A + B
    func addFunc(intA:Int, intB:Int) ->Int {
        return intA + intB
    }
    
    //    Swift4 中直接用 \ 作为开头创建 KeyPath
    func swift4_func1() {
        //创建一个User实例对象
        let user1 = User()
        user1.name = "hangge"
        user1.age = 100
        
        //使用KVC取值
        let name = user1.value(forKey: "name")
        print(name)
        
        //使用KVC赋值
        user1.setValue("hangge.com", forKey: "name")
    }
    
    //    Swift4 类与协议的组合类型
    func swift4_func2() {
        let myClass = MyClass()
        myClass.delegate = ViewSubclass() //这个编译正常
        myClass.delegate = View() as? (View & MyProtocol) //这个编译报错:
    }
    
    //    Swift4 类与协议的组合类型 - 方法2
    func swift4_func3(controls: [UIControl & Shakeable]) {
        for control in controls where control.isEnabled {
            control.shake()
        }
    }
    
    //    Swift4 下标的返回类型支持泛型
    //    Swift4 下标类型同样支持泛型
    func swift4_func4() {
        //字典类型: [String: Any]
        let earthData = GenericDictionary(data: ["name": "Earth", "population": 7500000000, "moons": 1])
        
        //自动转换类型，不需要在写 "as? String"
        let name: String? = earthData["name"]
        print(name)
        
        //自动转换类型，不需要在写 "as? Int"
        let population: Int? = earthData["population"]
        print(population)
        
        // Array下标
        let nameAndMoons = earthData[["moons", "name"]]        // [1, "Earth"]
        print(nameAndMoons)
        
        // Set下标
        let nameAndMoons2 = earthData[Set(["moons", "name"])]  // [1, "Earth"]
        print(nameAndMoons2)
    }
    
    //    Swift4 使用Codable序列化和反序列化 做数据存储准备
    func swift4_func5_EncodeAndDecode() {
        let swift = Language(name: "Swift", version: 4)
        
        //encoded对象
        let encodedData = try? JSONEncoder().encode(swift)
        
        //从encoded对象获取String
        let jsonString = String(data: encodedData!, encoding: .utf8)
        print(jsonString)
        
        let decodedData = try! JSONDecoder().decode(Language.self, from: encodedData!)
        print(decodedData.name, decodedData.version)
    }
    
    //    针对 Swift4 String的特性，这里对 String 进行扩展，新增一个 subString 方法。直接可以根据起始位置（Int 类型）和需要的长度（Int 类型），来截取出子字符串
    func swift4_func6() {
        let str1 = "欢迎访问hangge.com"
        let str2 = str1.subString(start: 4, length: 6)
        print("原字符串：\(str1)")
        print("截取出的字符串：\(str2)")
    }
    
    // 六、废除 swap 方法
    func swift4_func7() {
        //        废弃交换方法
        //        var a = 1
        //        var b = 2
        //        swap(&a, &b)
        //        print(a, b)
        
        //        后面 swap() 方法将会被废弃，建议使用 tuple（元组）特性来实现值交换，也只需要一句话就能实现：
        //        var a = 1
        //        var b = 2
        //        (b, a) = (a, b)
        //        print(a, b)
        
        //        使用 tuple 方式的好处是，多个变量值也可以一起进行交换：
        var a = 1
        var b = 2
        var c = 3
        (a, b, c) = (b, c, a)
        print(a, b, c)
        
        //        补充一下：现在数组增加了个 swapAt 方法可以实现两个元素的位置交换。
        var fruits = ["apple", "pear", "grape", "banana"]
        //交换元素位置（第2个和第3个元素位置进行交换）
        fruits.swapAt(1, 2)
        print(fruits)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// 一、Key Paths 新语法
// 用户类
class User: NSObject {
    var name:String = ""  //姓名
    var age:Int = 0  //年龄
}
// 二、类与协议的组合类型
protocol MyProtocol { }
class View { }
class ViewSubclass: View, MyProtocol { }
class MyClass {
    var delegate: (View & MyProtocol)?
}

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
// 三、下标支持泛型
struct GenericDictionary<Key: Hashable, Value> {
    private var data: [Key: Value]
    
    init(data: [Key: Value]) {
        self.data = data
    }
    
    subscript<T>(key: Key) -> T? {
        return data[key] as? T
    }
}
// Swift4 下标类型同样支持泛型
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
// 四、Codable 序列化
struct Language: Codable {
    var name: String
    var version: Int
}
// 五、Subtring 字符串操作
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
