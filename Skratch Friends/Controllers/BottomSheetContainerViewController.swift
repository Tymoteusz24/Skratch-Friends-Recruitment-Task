//
//  BottomSheetContainerViewController.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit

open class BottomSheetContainerViewController<BottomSheet: UIViewController> : UIViewController, UIGestureRecognizerDelegate {
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.alpha = 0.0
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        return view
    }()
    
    let image: UIImage?
    let position: CGRect!
    
    // MARK: - Initialization
    public init(bottomSheetViewController: BottomSheet,
                bottomSheetConfiguration: BottomSheetConfiguration, image: UIImage?, position: CGRect) {
        self.image = image
        self.position = position
        self.bottomSheetViewController = bottomSheetViewController
        self.configuration = bottomSheetConfiguration
        
        super.init(nibName: nil, bundle: nil)
        self.setupUI()
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet(animated: true, delay: 0.2)
        newAnimation(with: image, position: position)
    }
    
    // MARK: - Bottom Sheet Actions
    public func showBottomSheet(animated: Bool = true, delay: TimeInterval = 0.0) {
        self.topConstraint.constant = -configuration.height
        if animated {
            UIView.animate(withDuration: 0.2, delay: delay, animations: {
                self.view.layoutIfNeeded()
                self.backgroundView.alpha = 1.0
            }, completion: { _ in
                self.state = .full
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .full
        }
    }
    
    public func hideBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.initialOffset
       
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                            self.view.layoutIfNeeded()
                            self.backgroundView.alpha = 0.0
            }, completion: { _ in
                self.state = .initial
                self.dismiss(animated: false, completion: nil)
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .initial
        }
    }
    
    // MARK: - Pan Action
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: bottomSheetViewController.view)
        let velocity = sender.velocity(in: bottomSheetViewController.view)
        
        let yTranslationMagnitude = translation.y.magnitude
        
        switch sender.state {
        case .began, .changed:
            if self.state == .full {
                guard translation.y > 0 else { return }
                
                topConstraint.constant = -(configuration.height - yTranslationMagnitude)
                backgroundView.alpha = (1.0 - yTranslationMagnitude/configuration.height)
                
                self.view.layoutIfNeeded()
            } else {
                let newConstant = -(configuration.initialOffset + yTranslationMagnitude)
                
                guard translation.y < 0 else { return }
                guard newConstant.magnitude < configuration.height else {
                    self.showBottomSheet()
                    return
                }
                
                topConstraint.constant = newConstant
                
                self.view.layoutIfNeeded()
            }
        case .ended:
            if self.state == .full {
                
                if yTranslationMagnitude >= configuration.height / 2 || velocity.y > 1000 {
                    
                    self.hideBottomSheet()
                } else {

                    self.showBottomSheet()
                }
            } else {
                
                if yTranslationMagnitude >= configuration.height / 2 || velocity.y < -1000 {
                    
                    self.showBottomSheet()
                    
                } else {
                    self.hideBottomSheet()
                }
            }
        case .failed:
            if self.state == .full {
                self.showBottomSheet()
            } else {
                self.hideBottomSheet()
            }
        default: break
        }
    }
    
    // MARK: - Configuration
    public struct BottomSheetConfiguration {
        let height: CGFloat
        let initialOffset: CGFloat
    }
    
    private let configuration: BottomSheetConfiguration
    
    // MARK: - State
    public enum BottomSheetState {
        case initial
        case full
    }
    
    var state: BottomSheetState = .initial
    
    // MARK: - Children
    let bottomSheetViewController: BottomSheet
    
    // MARK: - Top Constraint
    private var topConstraint = NSLayoutConstraint()
    
    // MARK: - Pan Gesture
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(handlePan))
        return pan
    }()
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundView.frame = self.view.frame
        self.view.addSubview(backgroundView)
        self.addChild(bottomSheetViewController)
        
        self.view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.view.addGestureRecognizer(panGesture)
        
        bottomSheetViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = bottomSheetViewController.view.topAnchor
            .constraint(equalTo: self.view.bottomAnchor,
                        constant: -configuration.initialOffset)
        
        NSLayoutConstraint.activate([
            bottomSheetViewController.view.heightAnchor
                .constraint(equalToConstant: configuration.height),
            bottomSheetViewController.view.leftAnchor
                .constraint(equalTo: self.view.leftAnchor),
            bottomSheetViewController.view.rightAnchor
                .constraint(equalTo: self.view.rightAnchor),
            topConstraint
        ])
        
        bottomSheetViewController.didMove(toParent: self)
    }
    
    // MARK: - UIGestureRecognizer Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func dismissVC() {
        hideBottomSheet()
    }
}

//MARK:- Animating user avatar

extension BottomSheetContainerViewController {
    
    private var makeAnimationView: UIView {
        let animationView = UIView()
        animationView.frame = self.view.frame
        return animationView
    }
    
    private func newAnimation(with image: UIImage?, position: CGRect) {
        let animationView = makeAnimationView
        guard let bottomVC = bottomSheetViewController as? UserDatailsViewController,
              let image = image else {return}
        
        bottomVC.userImage.alpha = 0.0
        
        let userImage = UserAvatarImageView(image: image)
        userImage.translatesAutoresizingMaskIntoConstraints = true
        userImage.frame = position
        userImage.layer.cornerRadius = position.height/2
        animationView.addSubview(userImage)
        
        self.view.addSubview(animationView)
        self.view.bringSubviewToFront(animationView)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            bottomVC.userImage.alpha = 1.0
            animationView.removeFromSuperview()
        }
        
        let scaleAnimation = CABasicAnimation(keyPath:"transform.scale")
        let scale:CGFloat = 72/position.height
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = scale
        scaleAnimation.duration = 0.6
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        userImage.layer.add(scaleAnimation, forKey: "scale")
        
        let positionAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        let path = UIBezierPath()
        let center = CGPoint(x: self.view.bounds.center.x, y: UIScreen.main.bounds.height - 473)
        
        path.move(to: userImage.center)
        path.addCurve(to: center, controlPoint1: CGPoint(x: center.x/3, y: center.y/3), controlPoint2: CGPoint(x: center.x/3, y: center.y/4))
        positionAnimation.path = path.cgPath
        positionAnimation.repeatCount = 0
        positionAnimation.duration = 0.6
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        positionAnimation.isRemovedOnCompletion = false
        positionAnimation.fillMode = .forwards
        
        userImage.layer.add(positionAnimation, forKey: "position")
        CATransaction.commit()
    }
}
