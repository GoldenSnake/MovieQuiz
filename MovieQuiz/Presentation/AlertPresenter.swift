//
//  AlertPresenter.swift
//  MovieQuiz
//

import Foundation
import UIKit

class AlertPresenter {
    
    weak var controller: UIViewController?
        
        init(controller: UIViewController) {
            self.controller = controller
        }
    
    func showAlert(model: AlertModel) {
        guard let controller = controller else { return }
        
        let alert = UIAlertController(title: model.title, 
                                      message: model.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
