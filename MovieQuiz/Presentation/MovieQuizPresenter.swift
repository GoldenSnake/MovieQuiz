//
//  MovieQuizPresenter.swift
//  MovieQuiz
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate  {
    
    // MARK: - Private Properties
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService = StatisticServiceImplementation()
    
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        self.viewController?.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToReceiveNextQuestion(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
    }
    
    func didLoadEmptyData(errorMessage: String) {
        viewController?.hideLoadingIndicator()
        viewController?.showEmptyDataError(errorMessage: errorMessage) { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
    }
    // MARK: - Actions
    
    func noButtonClicked() {
        proceedWithAnswer(false)
    }
    
    func yesButtonClicked() {
        proceedWithAnswer(true)
    }
    
    // MARK: - Private Methods
    
    private func proceedWithAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = (givenAnswer == currentQuestion.correctAnswer)
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let viewModelResults = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                        message: message,
                                                        buttonText: "Сыграть еще раз")
            
            viewController?.show(quiz: viewModelResults) { [weak self] in
                self?.restartGame()
            }
            viewController?.borderColorClear()
            viewController?.changeStateButtons(isEnabled: true)
        } else {
            switchToNextQuestion()
            viewController?.borderColorClear()
            viewController?.changeStateButtons(isEnabled: true)
            viewController?.showLoadingIndicator()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}
