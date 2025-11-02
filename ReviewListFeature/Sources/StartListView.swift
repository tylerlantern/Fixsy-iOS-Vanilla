import SwiftUI

/*
 * Reference:
 * Star rating view in SwiftUI | Swift UI recipes
 * https://swiftuirecipes.com/blog/star-rating-view-in-swiftui
 */
public struct StarRatingView: View {
  private let theRating: Float
  private let color: Color // The color of the stars
  private let maxRating: Float // Defines upper limit of the rating
  private var needsComputing: Bool = false
  private let spcaing: CGFloat
  public init(
    rating: Float,
    spacing: CGFloat,
    color: Color = .orange,
    maxRating: Float = 5
  ) {
    self.theRating = rating
    self.color = color
    self.maxRating = maxRating
    self._rating = .constant(rating)
    self.spcaing = spacing
  }

  @Binding private var rating: Float

  public init(
    rating: Binding<Float>,
    spacing: CGFloat,
    color: Color = .orange,
    maxRating: Float = 5
  ) {
    self.theRating = rating.wrappedValue
    self.spcaing = spacing
    self.color = color
    self.maxRating = maxRating
    self._rating = rating
    self.needsComputing = true
  }

  public var body: some View {
    GeometryReader { geometry in
      let l: CGFloat = floor(geometry.size.height)
      let w: CGFloat = (l + self.spcaing) * CGFloat(self.maxRating)
      HStack(spacing: self.spcaing) {
        ForEach(0 ..< fullCount, id: \.self) { _ in
          self.fullStar.frame(width: l, height: l)
        }
        ForEach(0 ..< halfFullCount, id: \.self) { _ in
          self.halfFullStar.frame(width: l, height: l)
        }
        ForEach(0 ..< emptyCount, id: \.self) { _ in
          self.emptyStar.frame(width: l, height: l)
        }
      }
      .gesture(self.needsComputing ? tap(on: w) : nil)
    }
  }
}

extension StarRatingView {
  private var fullCount: Int {
    if self.needsComputing {
      return Int(self.rating)
    }
    return Int(self.theRating)
  }

  private var emptyCount: Int {
    if self.needsComputing {
      return Int(self.maxRating - self.rating)
    }
    return Int(self.maxRating - self.theRating)
  }

  private var halfFullCount: Int {
    (Float(self.fullCount + self.emptyCount) < self.maxRating) ? 1 : 0
  }
}

extension StarRatingView {
  private var fullStar: some View {
    Image(systemName: "star.fill")
      .resizable()
      .foregroundColor(self.color)
  }

  private var halfFullStar: some View {
    Image(systemName: "star.lefthalf.fill")
      .resizable()
      .foregroundColor(self.color)
  }

  private var emptyStar: some View {
    Image(systemName: "star")
      .resizable()
      .foregroundColor(self.color)
  }
}

extension StarRatingView {
  private enum SwipeDirection {
    case unknown
    case right
    case left
    case up
    case down
  }

  private func swipeDirection(_ translation: CGSize) -> SwipeDirection {
    /*
     * swipe - How to detect Swiping UP, DOWN, LEFT and RIGHT with SwiftUI on a View - Stack Overflow
     * https://stackoverflow.com/questions/60885532/how-to-detect-swiping-up-down-left-and-right-with-swiftui-on-a-view
     */
    switch (translation.width, translation.height) {
    case (0..., -30 ... 30): return .right
    case (...0, -30 ... 30): return .left
    case (-100 ... 100, ...0): return .up
    case (-100 ... 100, 0...): return .down
    default: return .unknown
    }
  }

  private func swipe(on length: CGFloat) -> some Gesture {
    /*
     * XXX:
     * minimumDistance が 0.0 なのは TapGesture のタップにも反応させるため
     */
    DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
      .onChanged { value in
        self.computeRating(with: value, on: length)
      }
      .onEnded { value in
        self.computeRating(with: value, on: length)
      }
  }

  private func computeRating(with value: DragGesture.Value, on length: CGFloat) {
    guard self.needsComputing else { return }

    let salt: CGFloat = 20
    var x = floor(value.location.x)
    guard x > -salt, x <= length + salt else { return }
    if x < 0.0 { x = 0.0 }
    let r = Float(round((x / length) * 100 * CGFloat(self.maxRating / 10)) / 10)
    switch self.swipeDirection(value.translation) {
    case .right, .left:
      self.rating = {
        let t = round(r)
        switch t {
        case 0.0: if r == 0.0 { return 0.0 }
        case self.maxRating: return self.maxRating
        default: break
        }
        return t > r ? t : t + 0.5
      }()
    default: break
    }
  }
}

extension StarRatingView {
  private func tap(on length: CGFloat) -> some Gesture {
    TapGesture(count: 1)
      .onEnded { _ in }
      .simultaneously(with: self.swipe(on: length))
  }
}

struct StarRatingView_Previews: PreviewProvider {
  @State static var rating: Float = 1.5

  static var previews: some View {
    Group {
//      StarRatingView(rating: 4,spacing: 8)
      StarRatingView(
        rating: 5.5,
        spacing: 8,
        color: .pink,
        maxRating: 7
      )
      // Changable with Swipe
      StarRatingView(rating: $rating, spacing: 8)
        .onChange(of: rating) { _, _ in
        }
    }
    .frame(width: 300, height: 30)
    .previewLayout(.fixed(width: 300, height: 40))
  }
}
