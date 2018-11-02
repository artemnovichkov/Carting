//
//  ExampleViewController.swift
//  ProjectTemplate
//
//  Created by Jan Misar on 28.08.18.
//  
//

import UIKit
import ReactiveSwift

final class ExampleViewController: BaseViewController {

    private weak var imageView: UIImageView!
    private weak var activityIndicator: UIActivityIndicatorView!
    private weak var reloadButton: UIButton!

    // MARK: Dependencies

    private let viewModel: ExampleViewModeling

    // MARK: Initializers

    init(viewModel: ExampleViewModeling) {
        self.viewModel = viewModel

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View life cycle

    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(hex: 0x78dd82)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(imageView.snp.width)
        }
        self.imageView = imageView

        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.tintColor = .black
        activityIndicator.hidesWhenStopped = true
        imageView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        self.activityIndicator = activityIndicator

        let reloadButton = UIButton()
        reloadButton.setTitle("Reload", for: [])
        reloadButton.setTitleColor(.black, for: [])
        view.addSubview(reloadButton)
        reloadButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        self.reloadButton = reloadButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
    }

    // MARK: Helpers

    private func setupBindings() {

        activityIndicator.reactive.isAnimating <~ viewModel.actions.fetchPhoto.isExecuting

        viewModel.actions.fetchPhoto <~ reloadButton.reactive.controlEvents(.touchUpInside).map { _ in }

        imageView.reactive.image <~ viewModel.photo

    }

}
