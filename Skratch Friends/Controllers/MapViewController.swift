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
    
    lazy var numberIndicator: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 24
        label.layer.masksToBounds = true
        label.layer.backgroundColor = UIColor.white.cgColor
        
        label.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        label.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        label.textColor = UIColor(red: 0.165, green: 0.18, blue: 0.263, alpha: 1)
        
        label.font = UIFont(name: "CircularStd-Medium", size: 24)
        
        label.textAlignment = .center
        
        label.text = "5"
        return label
    }()
    
    
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
    }
    
    private func configureUI() {
        self.view.addSubview(mapView)
        self.view.addSubview(segmentedControl)
        self.view.addSubview(numberIndicator)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedControl.setupShadow()
        numberIndicator.setupShadow()
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            numberIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            numberIndicator.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor)])
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

extension MapViewController {
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        guard let _ = userLocation, !userLocated else {return}
        mapView.setCenter(userLocation!.coordinate, zoomLevel: 3, animated: true)
        userLocated = true
    }
}

extension UIView {
    func setupShadow() {
        let layer = self.layer
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: bounds.width/2).cgPath
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
    }
}
