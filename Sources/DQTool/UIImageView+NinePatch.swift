//
//  UIImageView+NinePatch.swift
//  
//
//  Created by zhaoquan.du on 2023/2/28.
//

import UIKit
extension UIImage {
    //获取图片所有像素点颜色值数组
    func getRGBA() -> [[CGFloat]]? {
        guard let imageRef = self.cgImage else{
            return nil
        }
        guard let pixelData:Data = imageRef.dataProvider?.data as? Data else{
            return nil
        }
        let width = imageRef.width
        let height = imageRef.height
        let count = width * height * 4
        
        let rawData = [UInt8](pixelData)
        
        var byteIndex = 0
        
        var result = [[CGFloat]]()
        for _ in 0..<count/4 {
            let red = CGFloat(rawData[byteIndex]) / 255.0;
            let green = CGFloat(rawData[byteIndex + 1]) / 255.0;
            let blue = CGFloat(rawData[byteIndex + 2]) / 255.0;
            let alpha = CGFloat(rawData[byteIndex + 3]) / 255.0;
            byteIndex += 4
            result.append([red,green,blue,alpha])
        }
        return result
    }
    
    func  ninePatchImage(_ scale: Int = 3) -> UIImage{
        guard let imageRef = self.cgImage else{
            return self
        }

        guard let rgbaImage :[[CGFloat]] = getRGBA() else{
            return self
        }
        let scale:CGFloat = CGFloat(scale)
        
        //最上边一行的各像素点数组
        var topBarRgba:[[CGFloat]] = []
        for i in 1..<imageRef.width - 1 {
            topBarRgba.append(rgbaImage[i])
        }
        
        
        
        //最左边一排像素点数组
        var leftBarRgba = [[CGFloat]]()
        for i in 0..<rgbaImage.count {
            if i % imageRef.width == 0{
                leftBarRgba.append(rgbaImage[i])
            }
        }
        leftBarRgba.removeFirst()
        leftBarRgba.removeLast()


        guard let edge = stretchEdge(topBarRgba: topBarRgba, leftBarRgba: leftBarRgba) else {
            return self
        }
        
        if let  cgImage = self.cgImage?.cropping(to: CGRect(x: 1, y: 1, width: self.size.width - 2, height: self.size.height - 2)){
         
            var cropImage = UIImage.init(cgImage: cgImage, scale: CGFloat(scale), orientation: .up)
            cropImage = cropImage.resizableImage(withCapInsets: UIEdgeInsets(top: edge.top/scale, left: edge.left/scale, bottom: edge.bottom/scale, right: edge.right/scale),resizingMode: .stretch)
            return cropImage
            
        }
        

        return self
    }
    
    //点九图片内容区域边距
    func ninePatchContentInsets(_ scale: Int = 3) -> UIEdgeInsets?{
        guard let imageRef = self.cgImage else{
            return nil
        }

        guard let rgbaImage :[[CGFloat]] = getRGBA() else{
            return nil
        }
        let scale:CGFloat = CGFloat(scale)
        //最下边一行的各像素点数组
        var bottomBarRgba:[[CGFloat]] = []
        for i in (rgbaImage.count - imageRef.width + 1)..<rgbaImage.count - 1 {
            bottomBarRgba.append(rgbaImage[i])
        }
        
        //最右边一排像素点数组
        var rightBarRgba = [[CGFloat]]()
        for i in 0..<rgbaImage.count {
            if i % imageRef.width == imageRef.width - 1{
                rightBarRgba.append(rgbaImage[i])
            }
        }
        rightBarRgba.removeFirst()
        rightBarRgba.removeLast()
        
        guard let edge = stretchEdge(topBarRgba: bottomBarRgba, leftBarRgba: rightBarRgba) else{
            return nil
        }
        let edge1 = UIEdgeInsets(top: edge.top/scale, left: edge.left/scale, bottom: edge.bottom/scale, right: edge.right/scale)
        return edge1
    }
    
    private func stretchEdge(topBarRgba:[[CGFloat]],leftBarRgba:[[CGFloat]]) -> UIEdgeInsets?{
        var left = -1
        for i in 0..<topBarRgba.count {
            if topBarRgba[i][3] == 1 {
                left = i
                break
            }
        }
        if left == -1{
            return nil
        }
        var right = -1
        for i in (0..<topBarRgba.count).reversed() {
            if topBarRgba[i][3] == 1 {
                right = i
                break
            }
        }
        if right == -1{
            return nil
        }
        
        var top = -1
        for i in (0..<leftBarRgba.count) {
            if leftBarRgba[i][3] == 1 {
                top = i
                break
            }
        }
        if top == -1{
            return nil
        }
            
        
        var bottom = -1
        for i in (0..<leftBarRgba.count).reversed() {
            if leftBarRgba[i][3] == 1 {
                bottom = i
                break
            }
        }
        if bottom == -1{
            return nil
        }
        bottom = leftBarRgba.count - 1 - bottom
        right = topBarRgba.count - 1 - right
        
        return UIEdgeInsets(top: CGFloat(top), left: CGFloat(left), bottom: CGFloat(bottom), right: CGFloat(right))
    }
}

