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

Висновок: Оптимізований контейнер нияк нам не допоміг розмір залишився таким самим, тільки кількість шарів зменьшилася на 2, що я вважаю не суттево. Час збірки збільшився на хвилину.
Чому так сталося все дуже просто - оптимізація тут мінімальна тому що скрипт для створення мае меньше залежності ніж скрипт котрий використовуе модель.
Тому в нашому випадку (модель mobilenet_v2 та fastApi як бекенд) суттева оптимізація неможлива 
Також зрозуміло що використання можелі із ubuntu тільки погіршело становище з місцем. Єдине рішення котре я бачу в данному випадку знаяти ще більш специфічний контейнер котрий би мав в собі python та pytorch бібліотеки
![result.png](result.png)