# How-to Build/Start/Stop/Delete:
Для запуску скрипта що встановлюе всі залежності потрібно:
 * В папці із скриптом запустити термінал
 * Дати скрипту право на запуск: chmod +x install_dev_tools.sh
 * запустити скрипт з правами судо: sudo ./install_dev_tools.sh

Для того щоб збілдити fat або slim контейнер в залежності від обраної
 * Для fat: docker build -f Dockerfile.fat -t pytorch-stage:latest .
 * Для slim: docker build -f Dockerfile.slim -t pytorch-stage:latest .

Для того щоб запустити створений контейнер:
 * На той випадок якщо юзера не додано в группу докер(якщо додано можно без судо) та запск як демон щоб відпустити термінал: sudo docker run -d -p 8001:8001 pytorch-stage
 * Fastapi буде доступний за адресою:http://localhost:8001 
 * Також щоб перевірити модель користуемося swagger: http://localhost:8001/docs
 * Для зупинки контейнерів з імям pytorch-stage виконайте наступну команду: sudo docker ps -a | grep pytorch-stage | awk '{print $1}' | xargs -r sudo docker stop
 * Для видалення контейнерів з імям pytorch-stage виконайте наступну команду: sudo docker ps -a | grep pytorch-stage | awk '{print $1}' | xargs -r sudo docker rm -f
 * Для видалення образів з імям pytorch-stage виконайте наступну команду: sudo docker images | grep pytorch-stage | awk '{print $3}' | xargs -r sudo docker rmi -f

# For check of layers count and image size, time for building:

# Fat image: 
layers count: 17

docker history pytorch-fat | tail -n +2 | wc -l

image size: 7.03GB

docker images | grep pytorch-fat | awk '{print $7 $8}'

time for build: 600s


# Slim image:
layers count: 15

docker history pytorch-slim | tail -n +2 | wc -l

image size: 7.03GB

docker images | grep pytorch-slim | awk '{print $7 $8}'

time for build: 660s

Висновок: Оптимізований контейнер ніяк нам не допоміг розмір залишився таким самим, тільки кількість шарів зменьшилася на 2, що я вважаю не суттево. Час збірки збільшився на хвилину.
Чому так сталося все дуже просто - оптимізація тут мінімальна тому що скрипт для створення мае меньше залежності ніж скрипт котрий використовуе модель.
Тому в нашому випадку (модель mobilenet_v2 та fastApi як бекенд) суттева оптимізація неможлива 
Також зрозуміло що використання моделі із ubuntu тільки погіршело становище з місцем. Єдине рішення котре я бачу в данному випадку знайти ще більш специфічний контейнер котрий би мав в собі python та pytorch бібліотеки
![result.png](result.png)
