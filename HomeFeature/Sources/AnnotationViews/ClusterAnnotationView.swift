import MapKit
import UIKit

class WashStationClusterAnnotationView: ClusterAnnotationView {}
class PatchTireClusterAnnotationView: ClusterAnnotationView {}
class InflatingPointClusterAnnotationView: ClusterAnnotationView {}
class MotorcycleClusterAnnotationView: ClusterAnnotationView {}
class CarClusterAnnotationView: ClusterAnnotationView {}

class ClusterAnnotationView: MKAnnotationView {
  lazy var imv_icon: UIImageView = {
    let imv = UIImageView()
    imv.contentMode = .scaleAspectFit
    return imv
  }()

  lazy var lb_numberOfChildren: UILabel = {
    let lb = UILabel()
    lb.adjustsFontSizeToFitWidth = true
    lb.textAlignment = .center
    lb.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.init(500))
    lb.textColor = UIColor.white
    return lb
  }()

  private var _numberOfChildren: Int = 1 {
    didSet {
      setUp()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.sharedInitilization()
  }

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    self.sharedInitilization()
  }

  lazy var layerSmallerCircle: CAShapeLayer = {
    let l = CAShapeLayer()
    l.fillColor = UIColor.white.cgColor
    return l
  }()

  lazy var pathSmallerCircle: UIBezierPath = {
    let p = UIBezierPath()

    return p
  }()

  private func setUp() {
    if self.numberOfChildren < 1_000 {
      self.lb_numberOfChildren.text = String(self.numberOfChildren)
    } else {
      self.lb_numberOfChildren.text = String(floor(Double(self.numberOfChildren / 1_000)))
    }
    let diameter =
      CGFloat(roundf(45 * self.TBScaledValueForValue(value: self._numberOfChildren)))
    let newSize = CGSize(width: diameter, height: diameter)
    self.bounds.size = newSize
    self.layer.cornerRadius = diameter / 2
    self.lb_numberOfChildren.frame = self.bounds
    let center = self.TBRectCenter(rect: self.bounds)
    self.pathSmallerCircle.addArc(
      withCenter: center,
      radius: self.smallerSizeCircleRect.width,
      startAngle: 0,
      endAngle: CGFloat.pi * 2,
      clockwise: true
    )
  }

  override func prepareForReuse() {
    super.prepareForReuse()
  }

  func sharedInitilization() {
    self.backgroundColor = UIColor.black
    self.addSubview(self.lb_numberOfChildren)
  }

  var numberOfChildren: Int {
    get {
      self._numberOfChildren
    }
    set {
      self._numberOfChildren = newValue
    }
  }

  private let ratio: CGFloat = 0.25
  private var sizeCircle: CGSize {
    CGSize(
      width: self.bounds.width - (self.ratio * self.bounds.width),
      height: self.bounds.height - (self.ratio * self.bounds.width)
    )
  }

  private var smallerSizeCircleRect: CGRect {
    CGRect(x: 0, y: 0, width: self.sizeCircle.width - 10, height: self.sizeCircle.height - 10)
  }

  let TBScaleFactorAlpha: Float = 0.5
  let TBScaleFactorBeta: Float = 0.6
  func TBScaledValueForValue(value: Int) -> Float {
    1.0 /
      (1.0 + expf(-1 * self.TBScaleFactorAlpha * powf(Float(value), self.TBScaleFactorBeta)))
  }

  func TBCenterRect(rect: CGRect, center: CGPoint) -> CGRect {
    let r = CGRect(
      x: center.x - rect.size.width / 2.0,
      y: center.y - rect.size.height / 2.0,
      width: rect.size.width,
      height: rect.size.height
    )
    return r
  }

  func TBRectCenter(rect: CGRect) -> CGPoint {
    CGPoint(x: rect.midX, y: rect.midY)
  }
}
