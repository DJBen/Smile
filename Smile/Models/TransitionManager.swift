//
//  TransitionManager.swift
//  Smile
//
//  Created by Sihao Lu on 4/23/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    class var sharedManager : TransitionManager {
        struct Static {
            static let instance : TransitionManager = TransitionManager()
        }
        return Static.instance
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // TODO: Perform the animation
        let container = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let duration = self.transitionDuration(transitionContext)
        
        if let introVC = fromViewController as? IntroViewController, navVC = toViewController as? UINavigationController {
            let captureVC = navVC.viewControllers[0] as! PhotoCaptureViewController
            container.insertSubview(toView, belowSubview: fromView)
            if introVC.presentedCameraPermissionRequest {
                UIView.animateWithDuration(duration / 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                    introVC.mockAlertView.alpha = 0
                    introVC.mockAlertView.transform = CGAffineTransformMakeTranslation(0, 50)
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(duration / 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                        introVC.separatorView.transform = CGAffineTransformMakeTranslation(0, -40)
                        introVC.smileView.transform = CGAffineTransformMakeTranslation(0, -40)
                        introVC.smileView.alpha = 0
                        introVC.separatorView.alpha = 0
                        introVC.separatorView.alpha = 0
                        introVC.textView.alpha = 0
                    }, completion: { (_) -> Void in
                        UIView.animateWithDuration(duration / 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                            fromView.alpha = 0
                            }, completion: { (complete) -> Void in
                                transitionContext.completeTransition(complete)
                        })
                    })
                    
                })
            } else {
                UIView.animateWithDuration(duration / 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                    introVC.welcomeTextLabel.alpha = 0
                    introVC.welcomeTextLabel.transform = CGAffineTransformMakeTranslation(0, -50)
                    introVC.subtitleTextLabel.alpha = 0
                    introVC.subtitleTextLabel.transform = CGAffineTransformMakeTranslation(0, 50)
                }, completion: { (_) -> Void in
                    introVC.smileView.transform = CGAffineTransformIdentity
                    UIView.animateWithDuration(duration / 3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                        introVC.smileView.transform = CGAffineTransformMakeScale(0.001, 0.001)
                    }, completion: { (_) -> Void in
                        UIView.animateWithDuration(duration / 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                            fromView.alpha = 0
                        }, completion: { (complete) -> Void in
                                transitionContext.completeTransition(complete)
                        })
                    })
                })
            }

        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.2
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}
