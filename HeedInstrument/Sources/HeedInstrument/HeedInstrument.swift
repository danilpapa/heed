//
//  File.swift
//  HeedInstrument
//
//  Created by setuper on 08.03.2026.
//

import Foundation

public final class HeedInstrument {
    
    public static func start(
        exporter: HeedExporter = UDPExporter()
    ) {
        EventLogger.shared.setExporter(exporter)
        
        Heed.invoke {
            UIButtonSwizzling.self
            UIControlAddActionSwizzling.self
            UITextFieldSwizzling.self
            UIGestureRecognizerSwizzling.self
            UITableViewSwizzling.self
            UIViewControllerSwizzling.self
            UINavigationControllerSwizzling.self
            UIAlertControllerSwizzling.self
            URLSessionSwizzling.self
        }
        KeyboardObserver.shared.start()
        AppLifecycleObserver.shared.start()
    }
}
