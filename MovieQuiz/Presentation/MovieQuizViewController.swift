import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        borderColorClear()
        imageView.backgroundColor = .clear
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // Смена цвета статус-бара на белый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private Methods
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        changeStateButtons(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
       imageView.image = step.image
       textLabel.text = step.question
       counterLabel.text = step.questionNumber
   }
    
     func show(quiz result: QuizResultsViewModel) {
        let completion = { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            self.showLoadingIndicator()
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
    
     func showNetworkError(completion: @escaping () -> Void) {
        let alertError = AlertModel(title:"Что-то пошло не так(",
                                    message: "Невозможно загрузить данные",
                                    buttonText:"Попробовать ещё раз", 
                                    accessibilityIdentifier: "Network Error",
                                    completion: completion)
        alertPresenter = AlertPresenter(delegate: self)
        alertPresenter?.showAlert(model: alertError)
    }
    
     func showEmptyDataError(errorMessage: String, completion: @escaping () -> Void) {
        let alertError = AlertModel(title:"Что-то пошло не так(",
                                    message: errorMessage,
                                    buttonText:"Попробовать ещё раз", 
                                    accessibilityIdentifier: "Empty Data",
                                    completion: completion)
        
        alertPresenter = AlertPresenter(delegate: self)
        alertPresenter?.showAlert(model: alertError)
    }
    
    // функция которая делает рамку прозрачной
     func borderColorClear() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
     func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
        textLabel.text = ""
        imageView.alpha = 0.6
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        imageView.alpha = 1
    }
}
