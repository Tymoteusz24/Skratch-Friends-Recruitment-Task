//
//  MapViewController.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 23/04/2021.
//

import UIKit
import Mapbox
import BetterSegmentedControl

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    var numberIndicatorConstraints: [NSLayoutConstraint] = []
    
    lazy var mapView: MGLMapView = {
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        return mapView
    }()
    
    lazy var segmentedControl: BetterSegmentedControl = {
        let segmented = BetterSegmentedControl(
            frame: CGRect(x: 24.0, y: self.view.frame.height - 100.0, width: 138, height: 48.0),
            segments: IconSegment.segments(withIcons: [C.Image.mapSegmentedControlImage,C.Image.listSegmentedControlImage],
                                           iconSize: CGSize(width: 24.0, height: 24.0),
                                           normalIconTintColor: C.Color.gray,
                                           selectedIconTintColor: C.Color.purple),
            options: [.cornerRadius(25.0),
                      .backgroundColor(.white),
                      .indicatorViewBackgroundColor(C.Color.gray)])
        return segmented
    }()
    
    lazy var numberIndicator: PaddingTextField = {
        var textField = PaddingTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 24
        textField.layer.masksToBounds = true
        textField.layer.backgroundColor = UIColor.white.cgColor
        
        textField.textColor = UIColor(red: 0.165, green: 0.18, blue: 0.263, alpha: 1)
        
        textField.font = UIFont(name: "CircularStd-Medium", size: 24)
        
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        
        textField.text = "\(viewModel.numberOfUsers)"
        textField.placeholder = "No. of users"
        return textField
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 24
        button.backgroundColor = C.Color.purple
        button.clipsToBounds = true
        button.addTarget(self, action:#selector(handleRegister), for: .touchUpInside)
        button.isHidden = true
        button.layer.opacity = 0.0
        button.setImage(C.Image.checkmark, for: .normal)
        return button
    }()
    
    @objc func handleRegister() {
        print("tapped")
        viewModel.numberOfUsers = Int(numberIndicator.text ?? "5") ?? 5
        numberIndicator.text = "\(viewModel.numberOfUsers)"
        viewModel.populateMap() { [weak self] (err) in
            if let error = err {
                print(error)
            }
            
            print(self?.viewModel.users)
            DispatchQueue.main.async {
                guard let _ = self else {return}
                self!.mapView.removeAnnotations(self!.mapView.annotations!)
                self!.mapView.addAnnotations(self!.viewModel.annotationPoints)
            }
        }
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: - Properties
    
    private var viewModel: MapViewModel!
    
    var preciseButton: UIButton?
    
    var userLocated = false
    
    //MARK: - Init
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraints()
        
        
        viewModel.populateMap() { [weak self] (err) in
            if let error = err {
                print(error)
            }
            
            print(self?.viewModel.users)
            DispatchQueue.main.async {
                guard let _ = self else {return}
                self!.mapView.addAnnotations(self!.viewModel.annotationPoints)
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self,
              selector: #selector(self.keyboardNotification(notification:)),
              name: UIResponder.keyboardWillChangeFrameNotification,
              object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
      }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        confirmButton.frame = CGRect(x: UIScreen.main.bounds.width - 72, y: UIScreen.main.bounds.height - (endFrame?.size.height ?? 0.0) - 144 , width: 48, height: 48)
        CATransaction.commit()
       
        if endFrameY >= UIScreen.main.bounds.size.height {
            numberIndicatorConstraints[0].constant = -24
            numberIndicatorConstraints[1].constant = 48
            numberIndicatorConstraints[2].constant = 48
            numberIndicatorConstraints[3].constant = -42
            numberIndicator.textAlignment = .center
            numberIndicator.layer.cornerRadius = 24
            confirmButton.layer.opacity = 0.0
            confirmButton.isHidden = true
            numberIndicator.applyPadding = false
        } else {
            numberIndicatorConstraints[0].constant = 0
            numberIndicatorConstraints[1].constant = UIScreen.main.bounds.width
            numberIndicatorConstraints[2].constant = 72
            numberIndicatorConstraints[3].constant = -(endFrame?.size.height ?? 0.0)
            numberIndicator.applyPadding = true
            numberIndicator.textAlignment = .right
            numberIndicator.layer.cornerRadius = 0
            confirmButton.layer.opacity = 1.0
            confirmButton.isHidden = false
            
        }

        UIView.animate(
          withDuration: duration,
          delay: TimeInterval(0),
          options: animationCurve,
          animations: { self.view.layoutIfNeeded() },
          completion: nil)
      }
   

    
    private func configureUI() {
        self.view.addSubview(mapView)
        self.view.addSubview(segmentedControl)
        self.view.addSubview(numberIndicator)
        self.view.addSubview(confirmButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedControl.setupShadow()
        numberIndicator.setupShadow()
    }
    
    private func configureConstraints() {
        
        numberIndicatorConstraints = [
            numberIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            numberIndicator.widthAnchor.constraint(equalToConstant: 48),
            numberIndicator.heightAnchor.constraint(equalToConstant: 48),
            numberIndicator.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -42)
        ]
        
        NSLayoutConstraint.activate(numberIndicatorConstraints)
        confirmButton.frame = numberIndicator.frame
    }
    
    func mapView(_ mapView: MGLMapView, didChangeLocationManagerAuthorization manager: MGLLocationManager) {
        guard let accuracySetting = manager.accuracyAuthorization?() else { return }
        
        if accuracySetting == .reducedAccuracy {
            addPreciseButton()
        } else {
            
            removePreciseButton()
        }
    }
    
    func addPreciseButton() {
        let preciseButton = UIButton(frame: CGRect.zero)
        preciseButton.setTitle("Turn Precise On", for: .normal)
        preciseButton.backgroundColor = .gray
        
        preciseButton.addTarget(self, action: #selector(requestTemporaryAuth), for: .touchDown)
        self.view.addSubview(preciseButton)
        self.preciseButton = preciseButton
        
        // constraints
        preciseButton.translatesAutoresizingMaskIntoConstraints = false
        preciseButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        preciseButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        preciseButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0).isActive = true
        preciseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc private func requestTemporaryAuth() {
        let purposeKey = "MGLAccuracyAuthorizationDescription"
        mapView.locationManager.requestTemporaryFullAccuracyAuthorization!(withPurposeKey: purposeKey)
    }
    
    private func removePreciseButton() {
        guard let button = self.preciseButton else { return }
        button.removeFromSuperview()
        self.preciseButton = nil
    }
}

//MARK: - handling user location

extension MapViewController {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let _ = userLocation, !userLocated else {return}
        mapView.setCenter(userLocation!.coordinate, zoomLevel: 3, animated: true)
        userLocated = true
    }
}

//MARK: - Annotation, MGLMapViewDelegate methods

extension MapViewController {
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is UserAnnotationPoint else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CustomAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil, let customAnnotation = annotation as? UserAnnotationPoint {
            annotationView = CustomAnnotationView()
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 100, height: 90)
            if let image = viewModel.imagesDict[customAnnotation.user.picture.large] {
                annotationView!.backgroundColor = .clear
                annotationView!.imageView = image
                annotationView!.addSubview(annotationView!.imageView!)
                
                
                let label = Annotationlabel(text: customAnnotation.user.name.first)
                annotationView!.label = label
                annotationView!.addSubview(label)
                
                
                print("picture: get prefetched")
                return annotationView
            } else {
                customAnnotation.getImage { [weak self] (result) in
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            annotationView!.backgroundColor = .clear
                            annotationView!.imageView = image
                            self?.viewModel.imagesDict[customAnnotation.user.picture.large] = image
                            annotationView!.addSubview(annotationView!.imageView!)
                            
                            let label = Annotationlabel(text: customAnnotation.user.name.first)
                            annotationView!.label = label
                            annotationView!.addSubview(label)
                            
                            
                        }
                        
                    case .failure(let error):
                        print("error")
                    }
                }
                return annotationView
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
}

//
// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
    
    var imageView: UIImageView?
    
    var label: Annotationlabel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.borderWidth = 0
        imageView?.layer.borderWidth = 3
        imageView?.layer.borderColor = UIColor.white.cgColor
        imageView?.center = CGPoint(x: 50, y: 60)
        
        label?.center = CGPoint(x: 50, y: 10)
        
        guard let _ = imageView, let _ = label else {return}
        //self.layer.shadowPath = UIBezierPath(roundedRect: self.imageView!.frame, cornerRadius: self.imageView!.bounds.width/2).cgPath
        print("layoutet view with shadow ")
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.add(animation, forKey: "borderWidth")
    }
}

extension UIView {
    func setupShadow() {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: bounds.width/2).cgPath
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        
    }
}


extension UIImageView {
    func roundImageView(radius: CGFloat) {
        self.layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(self.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = roundedImage
    }
}


class UserAnnotationPoint: MGLPointAnnotation {
    private(set) var user: User!
    
    var imageName: String?
    
    init?(user: User) {
        super.init()
        self.user = user
        
        guard let coord = user.getCoordinates else {return nil}
        print("Configure: \(user.name)")
        self.coordinate = coord
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getImage(completion: @escaping (Result< UIImageView, NetworkError>) -> Void) {
        guard let url = URL(string: user.picture.large) else {
            completion(.failure(.domainError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                
                completion(.failure(.domainError))
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    let imageView = UIImageView(image: image.withAlignmentRectInsets(UIEdgeInsets(top: -3, left: -3, bottom: -3,
                                                                                                  right: -3)))
                    imageView.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
                    imageView.layer.cornerRadius = 30
                    imageView.layer.masksToBounds = true
                    imageView.contentMode = .scaleAspectFit
                    completion(.success(imageView))
                } else {
                    completion(.failure(.decodingError))
                }
            }
            
        }.resume()
    }
}
class Annotationlabel: UILabel {
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
        self.backgroundColor = .white
        self.textColor = C.Color.skratchNavy
        self.textAlignment = .center
        self.font = UIFont(name: C.Font.CircularStdBook, size: 12)
        self.sizeToFit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        let borderWidth: CGFloat = 4.0
        
        self.frame = self.frame.insetBy(dx: -borderWidth * 2, dy: -borderWidth)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 1
        
        self.clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
    }
}


class PaddingTextField: UITextField {
    var applyPadding: Bool = false

    private let padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return applyPadding ? bounds.inset(by: padding) : bounds
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return applyPadding ? bounds.inset(by: padding) : bounds
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return applyPadding ? bounds.inset(by: padding) : bounds
    }
}
