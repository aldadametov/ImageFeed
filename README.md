# Image Feed

## Ссылки

- [Дизайн в Figma](https://clck.ru/38ddGT)
- [Unsplash API](https://unsplash.com/documentation)
  
## Описание

Приложение представляет собой многостраничное приложение для просмотра изображений через API Unsplash. Пользователь может просматривать бесконечную ленту изображений, добавлять и удалять изображения из избранного, просматривать каждое изображение отдельно и делиться ссылкой на него за пределами приложения. Также доступен профиль пользователя с краткой информацией о нем.

## Технические требования

- Авторизация через OAuth Unsplash.
- Использование различных элементов интерфейса: `UIImageView`, `UIButton`, `UILabel`, `TabBarController`, `NavigationController`, `NavigationBar`, `UITableView`, `UITableViewCell`, `UIScrollView`.
- Поддержка устройств iPhone с iOS 13 и выше в портретном режиме.
- Использование системных шрифтов.

## Авторизация

Для входа в приложение необходимо пройти авторизацию через OAuth Unsplash.

## Функциональности

### Просмотр ленты

- Пользователь может просматривать изображения в ленте.
- Для каждого изображения доступны кнопка лайка и информация о дате загрузки.
- Доступна навигация между лентой и профилем через таб-бар.

### Профиль пользователя

- Пользователь может просмотреть свой профиль с краткой информацией о себе.

### Дополнительные возможности

#### Просмотр изображения на весь экран

- Пользователь может увеличить изображение до границ телефона и поделиться им.
- Доступен жестовый контроль для перемещения, зумирования и поворота изображения.
- Пользователь может загрузить или поделиться изображением.

#### Просмотр профиля пользователя

- Пользователь может просмотреть свой профиль и выйти из него.
- Поддерживается автоматическое заполнение данных профиля из Unsplash.

