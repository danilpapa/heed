//
//  UITableView+Instrumented.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

private enum HeedTableContext {
    static let proxyKey = "heed.table.proxy"
}

extension UITableView {

    @objc func hs_instrumented_setDelegate(_ delegate: UITableViewDelegate?) {
        guard let delegate else {
            hs_instrumented_setDelegate(nil)
            return
        }

        if delegate is HeedTableDelegateProxy {
            hs_instrumented_setDelegate(delegate)
            return
        }

        let proxy = (objc_getAssociatedObject(self, HeedTableContext.proxyKey) as? HeedTableDelegateProxy)
            ?? HeedTableDelegateProxy()
        proxy.forward = delegate
        objc_setAssociatedObject(self, HeedTableContext.proxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        hs_instrumented_setDelegate(proxy)
    }
}

final class HeedTableDelegateProxy: NSObject, UITableViewDelegate {

    weak var forward: UITableViewDelegate?

    override func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) { return true }
        return forward?.responds(to: aSelector) ?? false
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        forward
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventLog = EventLog(
            category: "UI",
            eventType: "tableSelect",
            detail: "UITableView section=\(indexPath.section) row=\(indexPath.row)"
        )
        EventLogger.shared.log(eventLog)
        forward?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}
