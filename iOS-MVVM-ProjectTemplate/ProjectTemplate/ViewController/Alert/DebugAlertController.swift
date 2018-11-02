//
//  AlertController.swift
//  ProjectTemplate
//
//  Created by Marek Fořt on 10/5/18.
//

import UIKit

final class DebugAlertController: BaseViewController {
    private let _title: String
    private let _description: String
    private weak var okButton: UIButton!

    // MARK: Initializers

    init(title: String, description: String?) {
        self._title = title
        self._description = description ?? ""

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View life cycle

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.text = _title
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(26)
        }

        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.textAlignment = .natural
        textView.font = UIFont(name: "Courier New", size: 10)
        textView.text = _description
        view.addSubview(textView)
        textView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.height.equalTo(300)
        }

        let okButton = UIButton(type: .system)
        okButton.setTitle(L10n.Basic.ok, for: [])
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        view.addSubview(okButton)
        okButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview().inset(15)
        }
        self.okButton = okButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        okButton.on { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}
