# quiz app

flutter app that fetches trivia questions from the open trivia database api and presents them as an interactive quiz.

## features
- fetches 10 easy general knowledge questions from opentdb api
- multiple choice answers shuffled so correct answer isnt always in the same spot
- green/red color feedback when you pick an answer
- progress bar showing how far through the quiz you are
- score tracking throughout the quiz
- final score screen with option to play again
- handles html entities from the api response
- error handling if the api call fails

## how to run
1. clone the repo
2. run `flutter pub get`
3. run `flutter run`

## project structure
- `lib/question.dart` — data model for a trivia question
- `lib/api_service.dart` — handles the http request and json parsing
- `lib/quiz_screen.dart` — main ui with stateful widget managing quiz logic
- `lib/main.dart` — entry point
