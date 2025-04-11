# Recipe App

This is a Recipe App built with Flutter. It allows users to search for recipes, view recipe details, manage their favorite recipes, and more.

## Table of Contents

1. Installation
2. Features
3. File Structure
4. Usage
5. Contributing
6. License

## Installation

1. Install dependencies:
    ```bash
    flutter pub get
    ```

2. Run the app:
    ```bash
    flutter run
    ```

## Features

- Search for recipes by ingredient or recipe name.
- View detailed information about each recipe.
- Manage favorite recipes.
- User authentication and profile management.
- Beautiful and user-friendly UI.

## File Structure

The project structure is as follows:

```
.
├── config
│   └── theme.dart
├── data
│   └── result_type.dart
├── firebase_options.dart
├── main.dart
├── models
│   ├── ingredient.dart
│   ├── recipe_model.dart
│   └── recipe_search_result.dart
├── screens
│   ├── account
│   │   ├── favourite_screen.dart
│   │   ├── home_screen.dart
│   │   ├── recipe_screen.dart
│   │   ├── root_screen.dart
│   │   ├── search_by_ingredient_screen.dart
│   │   ├── search_by_recipe_screen.dart
│   │   ├── search_result_screen.dart
│   │   ├── search_screen.dart
│   │   └── widgets
│   │       ├── bottom_app_bar.dart
│   │       ├── recipe_tab.dart
│   │       └── single_comment.dart
│   ├── auth_wrapper.dart
│   ├── login_screen.dart
│   ├── profile_page.dart
│   ├── register_screen.dart
│   └── splash_screen.dart
└── services
    └── api_service.dart
```

## Usage

1. **Home Screen**: Browse through various recipes.
2. **Search Screen**: Search for recipes by ingredient or recipe name.
3. **Recipe Screen**: View detailed information about a selected recipe.
4. **Favorite Screen**: Manage your favorite recipes.
5. **Profile Page**: View and edit your profile.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
