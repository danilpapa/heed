//
//  UIAction+.swift
//  HeedInstrument
//
//  Created by setuper on 13.03.2026.
//

import UIKit

private enum HeedUIActionContext {
    static let didLogUIActionKey = "heed.didLogUIAction"
    static let inTitleInitKey = "heed.inTitleInit"
}

extension UIAction {
    
    @objc(hs_instrumented_initWithHandler:)
    convenience init(hs_instrumented_handler handler: @escaping UIActionHandler) {
        if Thread.current.threadDictionary[HeedUIActionContext.inTitleInitKey] as? Bool == true {
            self.init(hs_instrumented_handler: handler)
            return
        }
        
        let wrapped: UIActionHandler = { action in
            if Thread.current.threadDictionary[HeedUIActionContext.didLogUIActionKey] as? Bool != true {
                Thread.current.threadDictionary[HeedUIActionContext.didLogUIActionKey] = true
                defer {
                    Thread.current.threadDictionary.removeObject(forKey: HeedUIActionContext.didLogUIActionKey)
                }
                
                let id = action.identifier.rawValue ?? ""
                let title = action.title
                let eventLog = EventLog(
                    debug_detail: "UIAction handler id=\(id) title=\(title)"
                )
                EventLogger.shared.log(eventLog)
            }
            handler(action)
        }
        
        self.init(hs_instrumented_handler: wrapped)
    }
    
    @objc(hs_instrumented_initWithTitle:image:identifier:discoverabilityTitle:attributes:state:handler:)
    convenience init(
        hs_instrumented_title title: String,
        image: UIImage?,
        identifier: UIAction.Identifier?,
        discoverabilityTitle: String?,
        attributes: UIMenuElement.Attributes,
        state: UIMenuElement.State,
        handler: @escaping UIActionHandler
    ) {
        let wrapped: UIActionHandler = { action in
            if Thread.current.threadDictionary[HeedUIActionContext.didLogUIActionKey] as? Bool != true {
                Thread.current.threadDictionary[HeedUIActionContext.didLogUIActionKey] = true
                defer {
                    Thread.current.threadDictionary.removeObject(forKey: HeedUIActionContext.didLogUIActionKey)
                }
                
                let id = action.identifier.rawValue ?? ""
                let eventLog = EventLog(
                    debug_detail: "UIAction handler id=\(id) title=\(action.title)"
                )
                EventLogger.shared.log(eventLog)
            }
            handler(action)
        }
        
        Thread.current.threadDictionary[HeedUIActionContext.inTitleInitKey] = true
        defer {
            Thread.current.threadDictionary.removeObject(forKey: HeedUIActionContext.inTitleInitKey)
        }
        
        self.init(
            hs_instrumented_title: title,
            image: image,
            identifier: identifier,
            discoverabilityTitle: discoverabilityTitle,
            attributes: attributes,
            state: state,
            handler: wrapped
        )
    }
}
