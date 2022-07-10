//
//  UIImageExtensions.swift
//  YourEyes
//
//  Created by Nguyen Thanh Nhut on 2022/07/10.
//

import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func toBase64(png: Bool = false) -> String? {
        return toBase64(withPrefix: nil, png: png)
    }
    
    func toBase64(withPrefix prefix: String?, png: Bool = false) -> String? {
        let data: Data?
        
        if png {
            data = pngData()
        } else {
            data = jpegData(compressionQuality: 0.9)
        }
        
        guard let imageData = data else { return nil }
        
        let base64EncodedString = imageData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithCarriageReturn)
        
        if let prefix = prefix {
            return prefix.appending(base64EncodedString)
        }
        return base64EncodedString
    }
}

