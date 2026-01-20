cmake_minimum_required(VERSION 3.16)

project(Mental_krisis_app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Находим необходимые компоненты Qt
find_package(Qt6 REQUIRED COMPONENTS Quick Network Sql)

qt_standard_project_setup(REQUIRES 6.8)

# Создаем исполняемый файл
qt_add_executable(appMental_krisis_app
    main.cpp
)

# Создаем QML модуль
qt_add_qml_module(appMental_krisis_app
    URI Mental_krisis_app
    VERSION 1.0
    QML_FILES
        Main.qml
)

# Ищем PostgreSQL (только на десктопе)
if(NOT ANDROID)
    find_package(PostgreSQL)
    if(PostgreSQL_FOUND)
        message(STATUS "PostgreSQL found, linking...")
        target_link_libraries(appMental_krisis_app
            PRIVATE Qt6::Quick Qt6::Network Qt6::Sql
            PostgreSQL::PostgreSQL
        )
    else()
        message(WARNING "PostgreSQL not found. Will use SQLite only.")
        target_link_libraries(appMental_krisis_app
            PRIVATE Qt6::Quick Qt6::Network Qt6::Sql
        )
    endif()
else()
    # На Android используем только SQLite
    message(STATUS "Android build - using SQLite only")
    target_link_libraries(appMental_krisis_app
        PRIVATE Qt6::Quick Qt6::Network Qt6::Sql
    )
endif()

# Настройки для Android
if(ANDROID)
    # Минимальная версия Android
    set(CMAKE_MINIMUM_REQUIRED_VERSION 21)

    # Добавляем разрешения Android
    qt_add_android_apk(appMental_krisis_app
        PACKAGE_NAME "org.qtproject.mental_krisis"
        DEPENDS "appMental_krisis_app"
    )

    # Настройки для сборки под Android
    set_target_properties(appMental_krisis_app PROPERTIES
        ANDROID_ABI "armeabi-v7a;arm64-v8a;x86;x86_64"
        ANDROID_STL "c++_shared"
    )
else()
    # Настройки для десктопа
    set_target_properties(appMental_krisis_app PROPERTIES
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
    )
endif()

include(GNUInstallDirs)
install(TARGETS appMental_krisis_app
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
