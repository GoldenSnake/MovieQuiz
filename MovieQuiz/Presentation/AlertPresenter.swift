//
//  AlertPresenter.swift
//  MovieQuiz
//


import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        guard let delegate = delegate else {return}
        
        let alert = UIAlertController( title: model.title,
                                       message: model.message,
                                       preferredStyle: .alert)
        alert.view.accessibilityIdentifier = model.accessibilityIdentifier
        
        let action = UIAlertAction(title: model.buttonText, style: .default) {  _ in
            model.completion()
        }
        
        alert.addAction(action)
        delegate.present(alert, animated: true)

    }
}
