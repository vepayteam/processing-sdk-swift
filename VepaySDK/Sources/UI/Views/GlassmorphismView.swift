import UIKit

@IBDesignable
public final class GlassmorphismView: UIView {

    // MARK: - Properties
    private let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear)
    var animationDuration: TimeInterval { animator.duration }
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var animatorCompletionValue: CGFloat = 0.35
    private let backgroundView = UIView()
    public override var backgroundColor: UIColor? {
        get {
            return .clear
        }
        set {}
    }

    public init(theme: CHTheme = .dark,
         density: CGFloat = 0.4,
         cornerRadius: CGFloat = .zero,
         distance: CGFloat = 10,
         animated: Bool = true) {
        super.init(frame: .zero)
        initialize()
        makeGlassmorphismEffect(theme: theme, density: density, cornerRadius: cornerRadius, distance: distance, animated: animated)
    }

    public init() {
        super.init(frame: .zero)
        initialize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
//        makeGlassmorphismEffect(theme: traitCollection.userInterfaceStyle == .light ? .light : .dark)
        makeGlassmorphismEffect(theme: .dark)
    }
    
    deinit {
        animator.pauseAnimation()
        animator.stopAnimation(true)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Public Method
    /// Apply glassmorphism effect to the CHGlassmorphismView
    public func makeGlassmorphismEffect(theme: CHTheme = .dark,
                                 density: CGFloat = 0.4,
                                 cornerRadius: CGFloat = .zero,
                                 distance: CGFloat = 10, animated: Bool = true) {
        self.setTheme(theme: theme, animated: animated)
        self.setBlurDensity(with: density, animated: animated)
        self.setCornerRadius(cornerRadius, animated: animated)
        self.setDistance(distance, animated: animated)
    }
    
    /// Customizes theme by changing base view's background color.
    /// .light and .dark is available.
    public func setTheme(theme: CHTheme, animated: Bool = true) {
        switch theme {
        case .light:
            self.blurView.effect = nil
            self.blurView.effect = UIBlurEffect(style: .light)
            self.blurView.backgroundColor = UIColor.clear
            self.animator.stopAnimation(true)
            self.animator.addAnimations {
                self.blurView.effect = nil
            }
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        case .dark:
            self.blurView.effect = nil
            self.blurView.effect = UIBlurEffect(style: .dark)
            self.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.animator.stopAnimation(true)
            self.animator.addAnimations {
                self.blurView.effect = nil
            }
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        if animated { self.animator.fractionComplete = animatorCompletionValue }
    }
    
    /// Customizes blur density of the view.
    /// Value can be set between 0 ~ 1 (default: 0.65)
    /// - parameters:
    ///     - density:  value between 0 ~ 1 (default: 0.65)
    public func setBlurDensity(with density: CGFloat, animated: Bool = true) {
        self.animatorCompletionValue = (1 - density)
        if animated { self.animator.fractionComplete = animatorCompletionValue }
    }
    
    /// Changes cornerRadius of the view.
    /// Default value is 20
    public func setCornerRadius(_ value: CGFloat, animated: Bool = true) {
        self.backgroundView.layer.cornerRadius = value
        self.blurView.layer.cornerRadius = value
        if animated { self.animator.fractionComplete = animatorCompletionValue }
    }
    
    /// Change distance of the view.
    /// Value can be set between 0 ~ 100 (default: 20)
    /// - parameters:
    ///     - density:  value between 0 ~ 100 (default: 20)
    public func setDistance(_ value: CGFloat, animated: Bool = true) {
        var distance = value
        if value < 0 {
            distance = 0
        } else if value > 100 {
            distance = 100
        }
        self.backgroundView.layer.shadowRadius = distance
    }
    
    // MARK: - Private Method
    private func initialize() {
        // backgoundView(baseView) setting
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(backgroundView, at: 0)
        backgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.cornerRadius = 20
        backgroundView.clipsToBounds = true
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundView.layer.shadowOpacity = 0.2
        backgroundView.layer.shadowRadius = 20.0
        
        // blurEffectView setting
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = 20
        blurView.backgroundColor = UIColor.clear
        blurView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: -1),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -1),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),
            blurView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 1),
            blurView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        ])
        
        // add animation for managing density
        animator.addAnimations {
            self.blurView.effect = nil
        }
        animator.fractionComplete = animatorCompletionValue // default value is 0.35
    }
    
    // MARK: - Theme
    public enum CHTheme {
        case light
        case dark
    }

}
