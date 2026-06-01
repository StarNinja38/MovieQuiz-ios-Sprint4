import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        // When
        let emptyData = Data()
        let question = QuizQuestion(imageData: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        // Then
        XCTAssertNil(UIImage(data: emptyData)) // пустые данные не создают UIImage
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

// MARK: - Mock

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}
