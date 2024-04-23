//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showAnswerResult(isCorrect: Bool)
    
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel, completion: @escaping () -> Void)
    
    func showNetworkError(completion: @escaping () -> Void)
    func showEmptyDataError(errorMessage: String, completion: @escaping () -> Void)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func changeStateButtons(isEnabled: Bool)
    func borderColorClear()
}

