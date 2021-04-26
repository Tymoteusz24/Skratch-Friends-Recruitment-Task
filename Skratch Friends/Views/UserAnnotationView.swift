//
//  UserAnnotationView.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit
import Mapbox
import Combine

class UserAnnotationView: MGLAnnotationView {
    
    var imageView: UIImageView?
    
    var label: Annotationlabel?
    
    private var cancellable: AnyCancellable?
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        imageView = nil
        label = nil
    }
    
    func getImage() {
        guard let userAnnotation = annotation as? UserAnnotationPoint else {return}
        
        guard let url = URL(string: userAnnotation.user.picture.large) else {
            return
        }
        cancellable = ImageLoader.shared.loadImage(from: url).sink { [unowned self] image in
            let imageView = UIImageView(image: image?.withAlignmentRectInsets(UIEdgeInsets(top: -3, left: -3, bottom: -3,
                                                                                          right: -3)))
            imageView.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
            imageView.layer.cornerRadius = 30
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFit
            
            self.backgroundColor = .clear
            self.imageView = imageView
           
            self.addSubview(self.imageView!)
            
            let label = Annotationlabel(text: userAnnotation.user.name.first)
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

