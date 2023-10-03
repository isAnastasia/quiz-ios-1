import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterDelegate?
    private var statisticService: StatisticService?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        
        alertPresenter = ResultAlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        
        questionFactory?.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        } 
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let  questionStep = QuizStepViewModel(
            image: UIImage.init(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            correctAnswers += 1
        }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        if currentQuestionIndex == questionsAmount - 1 {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10",
                buttonText: "Сыграть еще раз")
            didGameFinished(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            
        }
    }
    
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
        
        let resultMessage = [
            "Ваш результат: \(correctAnswers)/10",
            "Количество сыгранных квизов: \(statisticService.gamesCount)",
            "Рекорд \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))",
            "Средняя точность \(String(format: "%.2f",statisticService.totalAccuracy))%"].joined(separator: "\n")
        
        return resultMessage
    }
    
    private func didGameFinished(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let alertModel = AlertModel(
            title: result.title,
            message: makeResultMessage(),
            buttonText: result.buttonText,
            completion: {
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(alertModel: alertModel)
    }
}
