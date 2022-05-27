//
//  Notification_Extension.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/02.
//

import Foundation
import UIKit

extension Notification.Name {
    
    static let notifyMap = Notification.Name("notifyMap")
    static let notifyWeb = Notification.Name("notifyWeb")
}


extension Date {

    func toStringWithCurrentLocale() -> String {

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.string(from: self)
    }
}

extension UIColor {
    
    class var modeColor: UIColor {
        return UIColor(named: "modeColor")!
    }

    class var modeTextColor: UIColor {
        return UIColor(named: "modeTextColor")!
    }
}

extension UIImage {
    
    func resize(size _size: CGSize) -> UIImage? {
        
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizeSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizeSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizeSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

