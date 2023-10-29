import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterDelegate?
    private var presenter: MovieQuizPresenter!    
    private var moviesLoader: MoviesLoading = MoviesLoader()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = ResultAlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: {[weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.showLoadingIndicator()
            })
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func showResultAlert(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultMessage()
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter.restartGame()
            })
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
}
