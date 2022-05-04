//
//  Notification_Extension.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/02.
//

import Foundation

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
