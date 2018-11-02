//
//  ExampleViewModel.swift
//  ProjectTemplate
//
//  Created by Jan Misar on 28.08.18.
//  
//

import UIKit
import ReactiveSwift

protocol ExampleViewModelingActions {
    var fetchPhoto: Action<Void, UIImage?, RequestError> { get }
}

protocol ExampleViewModeling {
	var actions: ExampleViewModelingActions { get }

    var photo: Property<UIImage?> { get }
}

extension ExampleViewModeling where Self: ExampleViewModelingActions {
    var actions: ExampleViewModelingActions { return self }
}

final class ExampleViewModel: BaseViewModel, ExampleViewModeling, ExampleViewModelingActions {
    typealias Dependencies = HasExampleAPI

    let fetchPhoto: Action<Void, UIImage?, RequestError>

    var photo: Property<UIImage?>

    // MARK: Initializers

    init(dependencies: Dependencies) {
        fetchPhoto = Action { dependencies.exampleAPI.fetchPhoto(1)  // wired photo ID just for example
            .filterMap { URL(string: $0) }
            .observe(on: QueueScheduler())
            .filterMap { try? Data(contentsOf: $0) }
            .observe(on: QueueScheduler.main)
            .map { UIImage(data: $0) }
        }

        photo = Property(initial: nil, then: fetchPhoto.values)

        super.init()
        setupBindings()
    }

    // MARK: Helpers

    private func setupBindings() {

    }
}
