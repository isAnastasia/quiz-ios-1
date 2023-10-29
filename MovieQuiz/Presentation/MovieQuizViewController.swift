import UIKit

final class MovieQuizViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //private var currentQuestionIndex = 0
    //private var correctAnswers = 0
    
    //private let questionsAmount: Int = 10
    //private var currentQuestion: QuizQuestion?
    
    //private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterDelegate?
    private var statisticService: StatisticService?
    private var presenter: MovieQuizPresenter!
    
    private var moviesLoader: MoviesLoading = MoviesLoader()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //questionFactory = QuestionFactory(delegate: self, moviesLoader: moviesLoader)
        alertPresenter = ResultAlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        presenter = MovieQuizPresenter(viewController: self)
        
        //showLoadingIndicator()
        //questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate

//    func didReceiveNextQuestion(question: QuizQuestion?) {
//
//        imageView.layer.borderColor = UIColor.clear.cgColor
//        imageView.layer.borderWidth = 0
//        yesButton.isEnabled = true
//        noButton.isEnabled = true
//
//        presenter.didReceiveNextQuestion(question: question)
//    }
    
//    func didLoadDataFromServer() {
//        activityIndicator.isHidden = true
//        questionFactory?.requestNextQuestion()
//    }
//
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions
    
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
                //self.currentQuestionIndex = 0
                self.presenter.restartGame()
                //self.correctAnswers = 0
                //self.questionFactory?.requestNextQuestion()
                self.showLoadingIndicator()
                //self.questionFactory?.loadData()
            })
        alertPresenter?.showAlert(alertModel: alertModel)
    }
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let image = UIImage(data: model.image)
//
//        let  questionStep = QuizStepViewModel(
//            image: image ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//        return questionStep
//    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
//        if isCorrect {
//            correctAnswers += 1
//        }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            //self.presenter.correctAnswers = self.correctAnswers
            //self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)",
//                buttonText: "Сыграть еще раз")
//            didGameFinished(quiz: viewModel)
//        } else {
//            presenter.switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
    private func getCurrentDate (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy hh:mm"
        let dateFormatted = dateFormatter.string(from: date)
        return dateFormatted
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService else {
            assertionFailure("Error. Can't get statisticService")
            return ""
        }

        let date = getCurrentDate(date: statisticService.bestGame.date)
        
        let resultMessage = """
            Ваш результат: \(presenter.correctAnswers)/10
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))
            Средняя точность \(String(format: "%.2f",statisticService.totalAccuracy))%
        """
        return resultMessage
    }
    
    func showResultAlert(quiz result: QuizResultsViewModel) {
        //statisticService?.store(correct: correctAnswers, total: questionsAmount)
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(
            title: result.title,
            message: makeResultMessage(),
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter.restartGame()
                //self.correctAnswers = 0
                //self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
}
