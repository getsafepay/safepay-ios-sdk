import UIKit

protocol PaymentMethodItemDelegate: AnyObject {
    func didSelectPaymentMethod(_ item: PaymentMethodItem, paymentMethod: PaymentMethod)
}

class PaymentMethodItem: UIView {
    weak var delegate: PaymentMethodItemDelegate? // weak to avoid retain cycles
    let paymentMethod: PaymentMethod
    var selected: Bool = false {
        didSet {
            changeSelection()
        }
    }
    
    // Custom initializer to accept paymentMethod
    init(paymentMethod: PaymentMethod, frame: CGRect = .zero, delegate: PaymentMethodItemDelegate) {
        self.paymentMethod = paymentMethod // Initialize the property
        self.delegate = delegate
        super.init(frame: frame)
        setupView() // Setup the view with stack and subviews
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func changeSelection() {
        if let radioBtnImageView = viewWithTag(1) as? UIImageView {
            radioBtnImageView.image = UIImage(systemName: selected ? "circle.inset.filled" : "circle")
        }
    }
    
    private func notifyDelegate() {
        if selected {
            delegate?.didSelectPaymentMethod(self, paymentMethod: paymentMethod)
        }
    }
    
    // Set up the stack view and configure constraints
    private func setupView() {
        let radioBtnImageView = UIImageView()
        radioBtnImageView.tag = 1
        radioBtnImageView.tintColor = Colors.blue
        radioBtnImageView.image = UIImage(systemName: selected ? "circle.inset.filled" : "circle")
        radioBtnImageView.contentMode = .scaleAspectFit
        radioBtnImageView.translatesAutoresizingMaskIntoConstraints = false
        radioBtnImageView.widthAnchor.constraint(equalToConstant: 26).isActive = true
        radioBtnImageView.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        let CardTypeImageView = UIImageView()
        CardTypeImageView.tag = 2
        CardTypeImageView.image = UIImage.fromPod(named: paymentMethod.instrumentType)
        CardTypeImageView.contentMode = .scaleAspectFit
        CardTypeImageView.translatesAutoresizingMaskIntoConstraints = false
        CardTypeImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        CardTypeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let label = UILabel()
        CardTypeImageView.tag = 3
        label.text = "**** \(paymentMethod.last4)"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold) // Semi-bold system font
        label.textColor = Colors.fieldTextColor
        
        let stackView = UIStackView(arrangedSubviews: [radioBtnImageView, CardTypeImageView, label])
        stackView.tag = 4
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        // Add constraints to the stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onSelection))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func onSelection() {
        selected = true
        notifyDelegate()
    }
}
