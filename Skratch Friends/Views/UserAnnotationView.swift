//
//  UserAnnotationView.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit
import Mapbox
import Combine

protocol AnnotationDelegate: AnyObject {
    func didTap(for: User, image: UIImage?, position: CGRect)
}

class UserAnnotationView: MGLAnnotationView {
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.center = CGPoint(x: 50, y: 60)
        
        imageView.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    var label: Annotationlabel?
    
    weak var delegate: AnnotationDelegate?
    
    private var cancellable: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        // Use CALayer’s corner radius to turn this view into a circle.
        
        
       
        // user brezier path for better performance
        //self.layer.shadowPath = UIBezierPath(roundedRect: self.imageView!.frame, cornerRadius: self.imageView!.bounds.width/2).cgPath
       
        
    }
    
    @objc func imageTapped() {
        print("image tapped")
       setSelected(true, animated: true)
        guard let annotation = annotation as? UserAnnotationPoint else { return }
        guard let _ = avatarImageView.image, let _ = avatarImageView.globalFrame else {return}
        delegate?.didTap(for: annotation.user, image: avatarImageView.image, position: avatarImageView.globalFrame!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        avatarImageView.image = nil
        label = nil
    }
    
    func getImage() {
        guard let userAnnotation = annotation as? UserAnnotationPoint else {return}
        
        guard let url = URL(string: userAnnotation.user.picture.large) else {
            return
        }
        cancellable = ImageLoader.shared.loadImage(from: url).sink { [unowned self] image in

            self.avatarImageView.image = image?.withAlignmentRectInsets(UIEdgeInsets(top: -3, left: -3, bottom: -3, right: -3))
           
            self.addSubview(self.avatarImageView)
            
            let label = Annotationlabel(text: userAnnotation.user.name.first)
            label.center = CGPoint(x: 50, y: 10)
            self.label = label
            self.addSubview(label)
        }
    }
}

//MARK:- Custom annotation subviews

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

