import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func showAlert (alertModel: AlertModel)
}

final class ResultAlertPresenter: AlertPresenterDelegate {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    func showAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .cancel) {_ in
            alertModel.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}

