import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        let question = QuizQuestion(image: Data(), text: "Question Text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showAnswerResult(isCorrect: Bool) {
        
    }
    func show(quiz step: QuizStepViewModel){
        
    }
    func show(quiz result: QuizResultsViewModel, completion: @escaping () -> Void){
        
    }
    func showNetworkError(completion: @escaping () -> Void){
        
    }
    func showEmptyDataError(errorMessage: String, completion: @escaping () -> Void){
        
    }
    func showLoadingIndicator(){
        
    }
    func hideLoadingIndicator(){
        
    }
    func changeStateButtons(isEnabled: Bool){
        
    }
    func borderColorClear(){
        
    }
}
