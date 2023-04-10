//
//  File.swift
//  
//
//  Created by zhaoquan.du on 2022/12/20.
//

import UIKit

public extension UICollectionViewCell {
    
    
    /// 在Cell中找到对应的 UICollectionView
    var parentCollectionView : UICollectionView? {
        var view = self.superview
        while (view != nil && view!.isKind(of: UICollectionView.self) == false) {
            view = view!.superview
        }
        return view as? UICollectionView
    }
}


public extension Array {
    //数组去重
    //duplicate:返回true视为两个元素重复
    func filterDuplicates(by duplicate:(Element,Element) -> Bool) -> [Element]{
        var newArr = [Element]()
        self.forEach({ (ele) in
            if !newArr.contains(where: { duplicate($0,ele)}){
                newArr.append(ele)
            }
        })
        return newArr
    }
    
}
public extension Array where Element : Equatable {
    //数组去重
    func filterDuplicates() -> [Element] {
        var newArr = [Element]()
        self.forEach({ (str) in
            if !newArr.contains(str) {
                newArr.append(str)
            }
        })
        return newArr
    }
  
}

public extension UITableView {
    
    // 滑动到底部
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }

    // 滑动到顶部
    func scrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint.zero, animated: animated)
    }
    /// TableView 重载全部完成后执行的动作
    ///
    /// - Parameter completion: 完成后执行的动作
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    
    
    /// 选择全部Cell
    func selectAllRows(filter : ((IndexPath) -> Bool) = {_ in return true}) {
        for section in 0 ..< self.numberOfSections {
            for row in 0 ..< self.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if filter(indexPath) {
                    _ = self.delegate?.tableView?(self, willSelectRowAt: indexPath)
                    self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    self.delegate?.tableView?(self, didSelectRowAt: indexPath)
                }
            }
        }
    }
    
    
    /// 取消选择全部Cell
    func deselectAllRows() {
        for section in 0 ..< self.numberOfSections {
            for row in 0 ..< self.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                _ = self.delegate?.tableView?(self, willDeselectRowAt: indexPath)
                
                self.deselectRow(at: indexPath, animated: false)
                self.delegate?.tableView?(self, didDeselectRowAt: indexPath)
            }
        }
    }
}


public extension String {
    
    /// 字符串转时间
    ///
    /// - Parameter format: 时间格式
    /// - Returns: 时间
    func date(withFormat format: String = "dd/MM/yyyy HH:mm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    
    /// 文字复制到剪切板
    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
    
  
    func containMatch(_ string : String) -> Bool {
        self.localizedStandardContains(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}


public extension Date {
   
    
    /// Date 转 字符串
    ///
    /// - Parameter format: 时间格式
    /// - Returns: 时间字符串
    func string(withFormat format: String = "dd/MM/yyyy HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}


public extension UIView {
    
    /// 当前View保持与目标View等大
    ///
    /// - Parameter view: 目标View
    func equal(to view : UIView) -> Void {
        
        if !view.subviews.contains(self) {
            view.addSubview(self)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    //将当前视图转为UIImage
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            return nil
        }
    }
    
}

private weak var currentFirstResponder: AnyObject?

public extension UIResponder {
    //get first Responder
    static func firstResponder() -> AnyObject? {
        currentFirstResponder = nil
        // 通过将target设置为nil，让系统自动遍历响应链
        // 从而响应链当前第一响应者响应我们自定义的方法
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    @objc func findFirstResponder(_ sender: AnyObject) {
        // 第一响应者会响应这个方法，并且将静态变量currentFirstResponder设置为自己
        currentFirstResponder = self
    }
}

public extension Sequence where Element: Equatable {
    
    ///  检查是否包含另一序列的全部元素
    ///
    ///        [1, 2, 3, 4, 5].contains([1, 2]) -> true
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].contains([2, 6]) -> false
    ///        ["h", "e", "l", "l", "o"].contains(["l", "o"]) -> true
    ///
    /// - Parameter elements: 检查的元素组
    /// - Returns: 是否全部包含
    func contains(_ elements: [Element]) -> Bool {
        guard !elements.isEmpty else { return true }
        for element in elements {
            if !contains(element) {
                return false
            }
        }
        return true
    }
    
}

public extension Double {
   
    
    mutating func roundTo(decimals: Int = 2) -> Double {
        
        let c = "\(Int(self))".count
        var v = 18 - c
        if v < decimals {
            return self
        } else if v > 8 {
            v = 8
        }
        
        let t = pow(10.0, Double(v))
        
        var str: String = "\(Int((self * t).rounded()))"

        var number = Int(str)! / Int(pow(10.0, Double(v-decimals-1)))
        str = "\(number)"

        guard str.count > 0 else { return 0 }
        
        guard let dNumber = Int(str.suffix(1)) else {
            return 0
        }
        
        if dNumber > 4 {
            number = number + 10 - dNumber
        } else {
            number = number - dNumber
        }
        
        self = Double(number) / pow(10.0, Double(decimals+1))
        return self
    }
 
    
    func round2To(decimals: Int = 2) -> Double {
        var s: Double = (self * 100000000).rounded()
        s = s / 100000000
        
        s = (s * pow(10.0, Double(decimals))).rounded()
        s = s / pow(10.0, Double(decimals))
        
        return s == 0 ? 0 : s
    }

    
    
    mutating func doubleToString() -> String {
        
        var value = self
        
        var aa = value.roundTo(decimals: 6)

        let intValue = Int(aa)
        aa = aa - Double(intValue)
        aa = aa * 100000
        aa = aa.roundTo()
        
        if Int(aa) % 10 != 0 && aa > 0.0
        {
            return String(format:"%0.5f",self)
        }
        else if Int(aa) % 100 != 0 && aa > 0.0
        {
            return String(format:"%0.4f",self)
        }
        else if Int(aa) % 1000 != 0 && aa > 0.0
        {
            return String(format:"%0.3f",self)
        }
        else if Int(aa) % 10000 != 0 && aa > 0.0
        {
            return String(format:"%0.2f",self)
        }
        else if Double(Int(self))  == self && Int(self) > 0
        {
            return String(format:"%d",Int(self))
        }
        else
        {
            return String(format:"%0.1f",self)
        }
    }
    
    /**
     转换为带本地货币符号的字符串
     
     - returns: 带货币符号的字符串 例如： $12.34
     */
    func toCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        
        guard let returnStr = formatter.string(from: NSNumber(value: self)) else {
            return ""
        }
        
        //货币符号是一些少见的小国家时，输入的值很小，会直接会返回0，这种情况直接返回不带货币符号的原始输入值
        let str0 = formatter.string(from: NSNumber(value: 0))
        if let str1 = str0?.components(separatedBy: ".").first {
            if !str1.hasPrefix("CN") && !str1.hasPrefix("US") && str1.count >= 4 {  //$0.00,AMD0
                return String(format: "%.2f", self.round2To())
            }
        }
        return returnStr
    }
    
    func toCurrency4String() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        
        let returnStr = formatter.currencySymbol + String(format: "%.4f", self)
        
        //货币符号是一些少见的小国家时，输入的值很小，会直接会返回0，这种情况直接返回不带货币符号的原始输入值
        let str0 = formatter.string(from: NSNumber(value: 0))
        if let str1 = str0?.components(separatedBy: ".").first {
            if !str1.hasPrefix("CN") && !str1.hasPrefix("US") && str1.count >= 4 {  //$0.00,AMD0
                return String(format: "%.4f", self)
            }
        }
        return returnStr
    }
    
}

public extension Int {
    func sectionString() -> String{
        guard self > 999 else {
            return "\(self)"
        }
        var str = ""
        var number  = self
        while number > 0  {
            let n = number % 1000
            number = number / 1000
            
            var stemp = "\(n)"
            
            if number > 0 {
                if n < 10 {
                    stemp = "00" + stemp
                }else if n < 100{
                    stemp = "0" + stemp
                }
            }
            
            if str.isEmpty {
                str = stemp
            }else{
                str = stemp + "," + str
            }
            
            
        }
        
        return str
        
    }
}
