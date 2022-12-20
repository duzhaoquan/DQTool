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
