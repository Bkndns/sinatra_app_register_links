Ruby web-приложение, на фреймворке Sinatra, для простого учета посещенных (неважно, как, кем и когда) ссылок. Приложение предоставляет два HTTP ресурса. 
*POST /visited_links* и *GET /visited_domains?from=1545221231&to=1545217638*

# Установка
Процесс установки и запуска достаточно прост.
На компьютере должен быть установлен и запущен **Redis**

*Изначально планировалось сделать отдельный Gem для простоты установки, но в итоге эта идея была отброшена, также как идея залить проект на Heroku. В итоге, все манипуляции будем производить через Rake*

Устанавливаем **Rake** и **Bundler** если они еще не установлены

```
sudo gem install rake && sudo gem install bundler
```

Клонируем этот репозиторий

```
git clone https://github.com/adam-p/markdown-here.wiki.git
```

После клонирования, переходим в папку с проектом и вводим команду

```
rake --tasks
```

Эта команда выводит список доступных команд

```
rake app:binstall          # 1 - Install all dependencies (Bundler)
rake app:bserver_start     # 2 - Start Rack Server
rake app:bserver_test_req  # 3 - Test Request to Rack Server
rake app:dinsert_data      # 4 - Insert Test data to Rack Server
rake app:get_data          # 5 - Get data
rake app:print_get_curl    # 6 - Print curl GET request + timestamp now (for copy and paste in cons...
rake app:print_post_curl   # 7 - Print curl POST request (for copy and paste in console)
rake app:run_minitests     # 8 - Run all minitests
rake app:run_rspecs        # 9 - Run all RSpec Tests
```

Рекомендуется запускать команды по порядку.

Команда | Описание 
--- | ---
**rake app:binstall** | автоматически установит все зависимости которые прописаны в проекте
**rake app:bserver_start** | запускает Rack сервер для обработки HTTP запросов.
**rake app:bserver_test_req** | позволит быстро протестировать работоспособность толькочто созданного сервера
**rake app:dinsert_data** | Добавляет тестовые данные в Redis
**rake app:get_data** | Выводит на экран то, что храниться в Redis (последние добавленные даннык)
**rake app:print_get_curl** | Выведет в консоль curl команду для самостоятельного запуска GET запроса к серверу, достаточно просто скопировать команду и запустить.
**rake app:print_post_curl** | Выведет в консоль curl команду для самостоятельного запуска POST запроса к серверу, достаточно просто скопировать команду и запустить.
**rake app:run_minitests** | запустит и выведет результат тестирования всех minitests
**rake app:run_rspecs** | запустит и выведет результат тестирования всех тестов фреймворка RSpec

# Ручной запуск и проверка
Клонируем репозиторий
Устанавливаем зависимости
```
bundle install
```
Запускаем Rake сервер
```
rakeup
```
По умолчанию сервер запускается на порту 9292. Заходим и проверяем его работоспособность (браузер или curl в консоли)
```
curl http://localhost:9292
```
В ответ должны получить:
```
{"status"=>"Hello, World!"}
```
Если увидели такую надпись - поздравляю сервер запущен и работает.
Теперь проверим наши два HTTP ресурса. Чтобы данные отобразились, их нужно добавить. Скрипт использует **Redis** в качестве хранилища данных, поэтому он должен быть установлен и запущен на стандартном порте. Самое время сделать запрос на добавление тестовых данных:
```
curl -v -H 'Content-type: application/json' -X POST -d '{ "links": ["https://ya.ru", "https://ya.ru?q=123", "funbox.ru", "https://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor"] }' http://localhost:9292/visited_links
```
В ответ на этот запрос мы должны увидеть следующее
```
{"status"=>"ok"}
```
Теперь проверим, что же мы добавили выполнив GET запрос который принимает два параметра *from* - timestamp от временной метки и *to* - timestamp до временной метки. Пример запроса:
```
http://localhost:9292/visited_domains?from=1592080286&to=1592353724
```
В ответ мы должны увидеть следующее:
```
{
  "domains": [
    "di.fm",
    "radiorecord.ru",
    "yandex.ru",
    "example.ru",
    "funbox.ru",
    "google.com",
    "stackoverflow.com",
    "ya.ru"
  ],
  "status": "ok"
}
```
Поздравляю, наше Rack web-приложение работает.

# Структура проекта

```
- sinatra_app - корневая директория
-- specs - папка с RSpec тестами
-- tests - папка с minitest тестами
.env - файл содержащий переменные среды (конфигурации)
server.rb - Главный файл в котором происходит обработка всех событий
config.ru - файл для запуска Rack сервера
controller.rb - вспомогательный файл для обработки запросов сервера.
Gemfile - файл в котором описаны зависимости проекта
helpers.rb - общий вспомогательный файл. Содержит в себе функции различных проверок и валидаций
Rakefile - файл для запуска Rake. Автоматизация частых задач
```

*На этом всё.*
*Возможно, стоило всё это делать в одном Docker контейнере и поставлять сам контейнер...*
