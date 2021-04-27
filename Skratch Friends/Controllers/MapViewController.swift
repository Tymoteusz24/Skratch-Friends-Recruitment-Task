//
//  MapViewController.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 23/04/2021.
//

import UIKit
import Mapbox
import BetterSegmentedControl
import Combine

class MapViewController: UIViewController, MGLMapViewDelegate, ViewControllerForDetailVCProtocol {
    
    //MARK:- Views
    
    lazy var mapView: MGLMapView = {
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        return mapView
    }()
    
    lazy var segmentedControl: BetterSegmentedControl = {
        let segmented = BetterSegmentedControl(
            frame: CGRect(x: 24.0, y: UIScreen.main.bounds.height - 90.0, width: 138, height: 48.0),
            segments: IconSegment.segments(withIcons: [C.Image.mapSegmentedControlImage,C.Image.listSegmentedControlImage],
                                           iconSize: CGSize(width: 24.0, height: 24.0),
                                           normalIconTintColor: C.Color.paleBlue,
                                           selectedIconTintColor: C.Color.purple),
            options: [.cornerRadius(25.0),
                      .backgroundColor(.white),
                      .indicatorViewBackgroundColor(C.Color.gray)])
        segmented.addTarget(self, action: #selector(navigationSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmented
    }()
    
    lazy var numberIndicator: PaddingTextField = {
        var textField = PaddingTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "\(viewModel.numberOfUsers)"
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 24
        button.backgroundColor = C.Color.purple
        button.clipsToBounds = true
        button.addTarget(self, action:#selector(confirmTapped), for: .touchUpInside)
        button.isHidden = true
        button.layer.opacity = 0.0
        button.setImage(C.Image.checkmark, for: .normal)
        return button
    }()
    
    lazy var dimmView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    //MARK: - Properties
    
    private var numberIndicatorConstraints: [NSLayoutConstraint] = []
    
    private var friendListView: FriendListView?
    
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
        numberIndicator.delegate = self
        dimmView.frame = self.view.frame
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        
        viewModel.populateMap() { [weak self] (err) in
            if let error = err {
                print(error)
            }
            
            DispatchQueue.main.async {
                guard let _ = self else {return}
                self!.mapView.addAnnotations(self!.viewModel.annotationPoints)
                self!.friendListView?.tableView?.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedControl.setupShadow()
        numberIndicator.setupShadow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- General methodes
    
    private func configureUI() {
        self.view.addSubview(mapView)
        self.view.addSubview(segmentedControl)
        self.view.addSubview(numberIndicator)
        self.view.addSubview(confirmButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    private func showFriendList() {
        friendListView = FriendListView()
        friendListView?.frame = self.view.frame
        self.view.addSubview(friendListView!)
        friendListView!.tableView?.delegate = self
        friendListView!.tableView?.dataSource = self
    
        view.bringSubviewToFront(segmentedControl)
        view.bringSubviewToFront(numberIndicator)
        view.bringSubviewToFront(confirmButton)
        
    }
    
    private func hideFriendList() {
        UIView.animate(withDuration: 0.5) {
            self.friendListView?.alpha = 0.0
        } completion: { [weak self] (_) in
            self?.friendListView?.tableView?.delegate = nil
            self?.friendListView?.tableView?.dataSource = nil
            self?.friendListView?.tableView = nil
            self?.friendListView?.removeFromSuperview()
            self?.friendListView = nil
        }
        
    }
    
    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            hideFriendList()
        } else {
            showFriendList()
        }
    }
    
    @objc func confirmTapped() {
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
                self!.friendListView?.tableView?.reloadData()
                self!.mapView.removeAnnotations(self!.mapView.annotations!)
                self!.mapView.addAnnotations(self!.viewModel.annotationPoints)
            }
        }
        view.endEditing(true)
    }
}

//MARK:- Handling keyboard

extension MapViewController {
    
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
        CATransaction.setCompletionBlock {
            self.numberIndicator.textAlignment = endFrameY >= UIScreen.main.bounds.size.height ?
                .center:
                .right
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.dimmView.removeFromSuperview()
            }
        }
        confirmButton.frame = CGRect(x: UIScreen.main.bounds.width - 72, y: UIScreen.main.bounds.height - (endFrame?.size.height ?? 0.0) - 144 , width: 48, height: 48)
        CATransaction.commit()
        
        if endFrameY >= UIScreen.main.bounds.size.height {
            dimmView.alpha = 0.3
            numberIndicatorConstraints[0].constant = -24
            numberIndicatorConstraints[1].constant = 48
            numberIndicatorConstraints[2].constant = 48
            numberIndicatorConstraints[3].constant = -42
            numberIndicator.layer.cornerRadius = 24
            confirmButton.layer.opacity = 0.0
            confirmButton.isHidden = true
            numberIndicator.applyPadding = false
            numberIndicator.layer.shadowOpacity = 0.2
        } else {
            view.addSubview(dimmView)
            view.bringSubviewToFront(numberIndicator)
            view.bringSubviewToFront(confirmButton)
            dimmView.alpha = 1.0
            numberIndicatorConstraints[0].constant = 0
            numberIndicatorConstraints[1].constant = UIScreen.main.bounds.width
            numberIndicatorConstraints[2].constant = 72
            numberIndicatorConstraints[3].constant = -(endFrame?.size.height ?? 0.0)
            numberIndicator.applyPadding = true
            numberIndicator.layer.cornerRadius = 0
            confirmButton.layer.opacity = 1.0
            confirmButton.isHidden = false
            numberIndicator.layer.shadowOpacity = 0.0
        }
        
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
}

//MARK: - Handling user location

extension MapViewController {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let _ = userLocation, !userLocated else {return}
        mapView.setCenter(userLocation!.coordinate, zoomLevel: 3, animated: true)
        userLocated = true
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

//MARK: - Annotation, MGLMapViewDelegate methodes

extension MapViewController: AnnotationDelegate {
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is UserAnnotationPoint else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? UserAnnotationView
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil, let customAnnotation = annotation as? UserAnnotationPoint {
            annotationView = UserAnnotationView(frame: CGRect(x: 0, y: 0, width: 100, height: 90))
            annotationView!.annotation = customAnnotation
            //annotationView!.bounds = CGRect(x: 0, y: 0, width: 100, height: 90)
            annotationView!.getImage()
            annotationView!.delegate = self
            return annotationView
        }
        return annotationView
    }
    
    func didTap(for user: User, image: UIImage, position: CGRect) {
        showUserDetailsVC(for: user, image: image, position: position)
    }
}

//MARK:- Table view delegates & data source

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UserTableViewCell.self)") as! UserTableViewCell
        cell.configure(with: viewModel.users![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let users = viewModel.users else {return}
        
        guard let cell = friendListView?.tableView?.cellForRow(at: indexPath) as? UserTableViewCell else {return}
        
        
        showUserDetailsVC(for: users[indexPath.row],image: cell.userImage.image! ,position:  cell.userImage.globalFrame! )
    }
}

//MARK:- TextField delegates

extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        numberIndicator.text = "\(viewModel.numberOfUsers)"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        confirmButton.isEnabled = false
        mapView.isUserInteractionEnabled = false
        friendListView?.isUserInteractionEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        mapView.isUserInteractionEnabled = true
        friendListView?.isUserInteractionEnabled = true
        guard let num = Int(textField.text ?? "")  else {
            textField.text = "\(viewModel.numberOfUsers)"
            return
        }
        let shrink = num > 999 ? true : false
        numberIndicator.changeFontSize(shrink: shrink)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let num = Int(textField.text ?? ""), num > 0 else {
            confirmButton.isEnabled = false
            return}
        confirmButton.isEnabled = true
    }
}

