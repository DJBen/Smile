//
//  Additions.swift
//  Smile
//
//  Created by Sihao Lu on 4/23/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit

extension UIViewController {
    func makeNavigationBarTransparent(titleFont: UIFont = UIFont.freightSansFontWithStyle(.Book, size: 21)) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.5)
        shadow.shadowOffset = CGSizeMake(1, 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: titleFont, NSShadowAttributeName: shadow]
    }
}

extension CGRect {
    func resemblesRect(rect: CGRect, withError errorRect: CGRect) -> Bool {
        let xLike = abs(origin.x - rect.origin.x) <= abs(errorRect.origin.x)
        let yLike = abs(origin.y - rect.origin.y) <= abs(errorRect.origin.y)
        let widthLike = abs(width - rect.width) <= abs(errorRect.width)
        let heightLike = abs(height - rect.height) <= abs(errorRect.height)
        return xLike && yLike && widthLike && heightLike
    }
}