import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private let presenter = MovieQuizPresenter()

    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private let statisticService: StatisticService = StatisticServiceImplementation()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        borderColorClear()
        imageView.backgroundColor = .clear
        activityIndicator.hidesWhenStopped = true
        
        presenter.viewController = self
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    // Смена цвета статус-бара на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didFailToReceiveNextQuestion(with error: Error) {
        hideLoadingIndicator()
        showNetworkError { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
    }
    
    func didLoadEmptyData(errorMessage: String) {
        hideLoadingIndicator()
        showEmptyDataError(errorMessage: errorMessage) { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private Methods
    
     func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
     func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        changeStateButtons(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let message = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let viewModelResults = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                        message: message,
                                                        buttonText: "Сыграть еще раз")
            show(quiz: viewModelResults)
            
            borderColorClear()
            changeStateButtons(isEnabled: true)
        } else {
            presenter.switchToNextQuestion()
            borderColorClear()
            changeStateButtons(isEnabled: true)
            showLoadingIndicator()
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
        
        let alertResult = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            accessibilityIdentifier: "Results",
            completion: completion)
        
        alertPresenter = AlertPresenter(delegate: self)
        alertPresenter?.showAlert(model: alertResult)
    }
    
    // функция которая делает рамку прозрачной
    private func borderColorClear() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
        textLabel.text = ""
        imageView.alpha = 0.6
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        imageView.alpha = 1
    }
    
    private func showNetworkError(completion: @escaping () -> Void) {
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        let alertError = AlertModel(title:"Что-то пошло не так(",
                                    message: "Невозможно загрузить данные",
                                    buttonText:"Попробовать ещё раз", 
                                    accessibilityIdentifier: "Network Error",
                                    completion: completion)
        alertPresenter = AlertPresenter(delegate: self)
        alertPresenter?.showAlert(model: alertError)
    }
    
    private func showEmptyDataError(errorMessage: String, completion: @escaping () -> Void) {
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        let alertError = AlertModel(title:"Что-то пошло не так(",
                                    message: errorMessage,
                                    buttonText:"Попробовать ещё раз", 
                                    accessibilityIdentifier: "Empty Data",
                                    completion: completion)
        
        alertPresenter = AlertPresenter(delegate: self)
        alertPresenter?.showAlert(model: alertError)
    }
}
