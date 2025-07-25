
  

#  ``VepaySDK``

  

Библиотека позволяющая проводить трансграничные переводы, основываясь на технологиях Vepay

> Для iOS 13 и выше

  

  

  

## Начало работы

  

### Демо

  

Вы можете попробовать библиотеку запустив запустив VepaySDKExample target.

В нём у вас будет будет возможность выбрать между несколькими вариантами работы, так же вы можете создать и затестить ваш флоу во вкладке Custom

  

Для начала работы с библиотекой вам понадобиться ****X-User****

Для большей информации вы можете обратиться к пункту [Как получить X-User](#X-User)

  

  

### Подключение

  

Варианты подключения:

  

#### CocoaPods:

  

> pod 'VepaySDK'

  

##### Либо вы можете скопировать папку VepaySDK в ваш проект

  

  

## Главные объекты

  

  

### VepayPaymentController

  

UIViewController который показывает экран оплаты

  

Работа с ним предполагается как SubView для вашего главного экрана

  

Пример взаимодействия с ним, вы можете посмотреть в демо [PayController](#https://github.com/vepayteam/processing-sdk-swift/blob/main/VepaySDKExample/Main/PayController.swift)

  

#### В нём есть [CardView](#CardView)

  

Он загружается из Xib файла, что происходит после инициализации VepayPaymentController'a, поэтому для взаимодействия с ним вы можете использовать cardViewConfiguration в VepayPaymentController

  

#### Встроенный менеджмент карт

  

На данный момент находиться в работе

> Вы можете отключить галочку сохранения поставив hideRemberCard = true

  

#### Показ ошибок

  

Для показа ошибок вы можете использовать showError(message:, durationToDisappear:)

Либо вы можете добавить ваш UI в bottomStackView

  

###  <a name="Vepay3DSController"></a>Vepay3DSController

  

###  <a name="Vepay3DSController"></a>[Vepay3DSController](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L10C1-L19C2)

 

Вы можете использовать sseHandler, для работы с SSE

  

> Для работы с котроллером, предполгается использование его как childController

> <br />[пример работы с Vepay3DSController](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDKExample/PayController.swift#L96C5-L129C6)

  

Цикл работы c контроллером:

1. Инициализация Vepay3DSController()

2. Настроить [SSE](#SSE), если хотите можете использовать [встроенный SSE](#Работа с SSE)

3. [настроить показ 3DS](#Показ 3DS)

  

Так же вы можете использовать методы start, которые вернут вам настроенный контроллер

Их вы можете посмотреть в [Vepay3DSController+Start](#https://github.com/vepayteam/processing-sdk-swift/blob/main/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController%2bStart.swift)

  

###  <a name="CardView"></a>CardView

  

Вы можете использовать delegate, для отслежки прогресса и идентификации карты

  

UIView в котором 3 TextField'a:

- cardNumberField:

- cardNumber

- cardMasked

- usePaymentServiceIndetificationFlow

- paymentServiceIdentifier

- paymentService

CardNumberField Переменные конфигурации:

- validateMinDay. False если не надо валидировать minDay

- minDay & maxDay. Дни для проверки

  

- expirationDateField

- removeExpirtionDate

- expirationDate

- expirationDateRow

- expirationDateMasked

- cvvField

- removeCVV

- cvv

- Чтобы настроить длину CVV кода: cvvField.cvvMinCount || cvvMaxCount

  

Для отслеживания прогресса вписания вы можете использовать totalProgress & ready

  

  

#### NFC & Camera чтобы вписать карту

  

На данный момент находиться в работе

  

Чтобы убрать скрыть

hideAddCardViaNFC

hideAddCardViaCamera

  

Чтобы хендлить самому

overrideAddCardViaNFC

overrideAddCardViaCamera

  

  

###  <a name="EventSource"></a>EventSource

  

  

## Запросы

  

Есть 2 удобных способа выполнения запроса:

- Через метод класса [VepayBaseRequest](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/SupportingFiles/VepayBaseRequest.swift#L11)

  

[func request(

sessionHandler: VepaySessionHandler,

completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void)](#)

  

- Каждый запрос в SDK соответсвует протоколу [VepayRequest](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/SupportingFiles/VepayRequestBasis.swift#L11C1-L13C2), в котором есть приятный метод

  

[request(

sessionHandler: VepaySessionHandler,

success: @escaping (ResponseType) -> Void,

error: @escaping (VepayError) -> Void)](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/SupportingFiles/VepayRequestBasis.swift#L18C5-L22C6)

  

Вы можете оверрайднуть параметр [sessionHandler: VepaySessionHandler](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/SupportingFiles/VepayRequestHandler.swift#L13C1-L21C2)

<br /> по дефолту используется [VepayDefaultSessionHandler](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/SupportingFiles/VepayRequestHandler.swift#L27), который является Singleton'ом

  

  

### Последоватольность

  

1. Вначале вам нужно [создать счёт](#Создание); в ответ вы получаете [VepayInvoice](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayInvoice.swift#L12-L126) с [идентификатором счёта](#Идентификаторы)

2. По полученному uuid, вы [оплачиваете счёт](#Оплата)

3. Дальше для получение обновления статуса платежа, установите [SSE соединение](#SSE)

4. И если потребуется, [пройдите 3DS](#3DS)

  

  

### H2H

  

  

####  <a name="Cоздание"></a>[Cоздание Счёта](#https://test.vepay.online/h2hapi/v1#/default/post_invoices)

При создании инвойса вам понадобиться [externalID: String](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayInvoice.swift#L28C5-L32C34), вы можете это сделать используя [UUID().uuidString](#https://developer.apple.com/documentation/foundation/uuid/1780249-init)

  

> В ответ вы получаете [VepayInvoice](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayInvoice.swift#L12-L126) в котором будет <a name="Идентификаторы">два идентификатора счёта

> - uuid - Главный идентификатор, с ним работают все запросы

> - id - Является устаревшим

>

> По ним происходят все операции

  

[VepayInvoiceCreate](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceCreate.swift#L14C5-L19C6)([invoice: VepayInvoice](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayInvoice.swift#L12-L126), [xUser: String](#User))

  

  

####  <a name="Созданный"></a>[Получить Объект Счёта](#https://test.vepay.online/h2hapi/v1#/default/get_invoices__id_)

  

> Возращает счёт по его иднетификатору

  

[VepayInvoiceGet](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceGet.swift#L15C5-L19C6)([uuid: String](#Идентификаторы), [xUser: String](#User))

  

  

####  <a name="Оплата"></a>[Сделать Оплату Счёта](#https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment)

В параметре [form](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L13C1-L55C2), вам понадобиться ввести размеры экрана в котором будет отображаться [3DS](#3DS) (WebView bounds)

  

> В ответ вы получаете [VepayPaymentResponse](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L185), в котором указывается нужно ли проводит 3DS

<br />Вы можете использовать свойство [readable](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L223C9-L247C10), для удобного просмотра ответа

  

[VepayInvoicePayment](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoicePayment.swift#L16C5-L21C6)([uuid: String](#Идентификаторы), [form: VepayPayment](#VepayPayment), [xUser: String](#User))

  

[VepayInvoicePayment](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoicePayment.swift#L24C5-L28C6)([invoice: VepayInvoice](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayInvoice.swift#L12-L126), [form: VepayPayment](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L36C5-L41C6), [xUser: String](#User))

  

[VepayInvoicePayment](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoicePayment.swift#L31C5-L34C6)([invoice: VepayInvoice](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayInvoice.swift#L12-L126), [card: VepayPaymentCard, specificIPVersion: VepayUtils.IPVersion?, size: CGSize](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L46C5-L53C6), [xUser: String](#User))

  

  

####  <a name="Оплаченный"></a>[Получить Объект Оплаты](#https://test.vepay.online/h2hapi/v1#/default/get_invoices__id__payment)

  

> Возращает [объект оплаты](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L185), в котором, если нужно, будут указаны [данные для проведения 3DS](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L202C9-L221C53)

  

[VepayInvoiceGetPayment](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceGetPayment.swift#L15C5-L19C6)([uuid: String](#Идентификаторы), [xUser: String](#User))

  

  

####  <a name="3DS"></a>Выполнить 3DS

  

> Данные для 3DS'a получается в ответе оплаты, в объекте [VepayPaymentResponse.Redirect](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Models/H2H/VepayPayment.swift#L200C5-L249C6)

  

[VepayMake3DS(url: String, method: String, postParameters: [String: String]?)](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayMake3DS.swift#L16C5-L18C6)

  

  

####  <a name="Возрат"></a>[Сделать Возрат Средств](#https://test.vepay.online/h2hapi/v1#/default/post_invoices__id__payment_refunds)

  

[VepayInvoiceRefund](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceRefund.swift#L17C5-L22C6)([uuid: String](#Идентификаторы), [amount: Int](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceRefund.swift#L17C5-L22C6), [xUser: String](#User))

  

  

####  <a name="Возращённый"></a>[Получить Объект Возрата Средств](#https://test.vepay.online/h2hapi/v1#/default/get_invoices__id__payment)

  

[VepayInvoiceRefundGet](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceRefundGet.swift#L14C5-L18C6)([uuid: String](#Идентификаторы), [xUser: String](#User))

  

  

####  <a name="Отмена"></a>[Сделать Отмену Платежа](#https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment_reversed)

  

[VepayInvoiceCancel](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/Requests/H2H/VepayInvoiceCancel.swift#L14C5-L18C6)([uuid: String](#Идентификаторы), [xUser: String](#User))

  

  

##  <a name="SSE"></a>SSE

  

В СДК есть объект [Event Source](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/EventSource/EventSource.swift#L14C20-L14C31), который является реализацией [Server-sent events](#https://html.spec.whatwg.org/multipage/server-sent-events.html)

<br />Для работы с ним, вам понадобиться [ссылка](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L50C9-L50C96), по которой будет отслеживаться статус, и овверайднуть [delegate](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/EventSource/EventSourceDelegate.swift#L8), вы это можете сделать при [инициализации](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/EventSource/EventSource.swift#L49C5-L57C6) либо через метод [set(delegate:)](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/Networking/EventSource/EventSource.swift#L63C5-L65C6)

  

В целом, Event Source достаточно самостоятелен, поэтому вы можете просто оверрайднуть метод [new(event:)](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L67C5-L76C6)

  

> Так же для облегчения работы с SSE, в библиотеке есть [Vepay3DSController](#Vepay3DSController)

  

## Handy Trick

  

  

####  <a name="Start Vepay3DSController"></a>Start

  

Есть 2 вида старта:

- [start](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L85C5-L119C6) - Просто выполняет запрос VepayMake3DS

- [getAndStart](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L121C5-L147C6) - Получает данные статуса оплаты и если нужно оплатить оплачивает

  

> Оба метода возращают контроллер, с настроенным показом 3DS

  

  

####  <a name="Работа с SSE"></a>Работа с SSE

  
Работа с SSE реализуется через [EventSource](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/SSE/EventSource.swift)

Для упрощения работы с ним, вы можете использовать [VepaySSEHandler](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/SSE/VepaySSEHandler.swift)

 
Вы можете инициализовать 2 способами:

1. С созданием SSE через ссылку
2. Пустое создание. 
Для того чтобы создать SSE на своей стороне и установить его в ручную через set(sse:)

По дефолту он читает сообщение в
open  func  onMessage(eventType: String, messageEvent: MessageEvent)

и если в нём есть "status" постарается его задекодить 

Вы можете сделать subclass VepaySSEHandler, для того чтобы изменить все поведения
  

  

####  <a name="Показ 3DS"></a>Показ 3DS

  

Для настройки отображения 3DS используется метод [show3DS](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L44C5-L47C6)

  

> Вы можете посмотреть пример показа, в методе [start](#https://github.com/vepayteam/processing-sdk-swift/blob/b4dc9bb89211e33d6efa899e2ecaae5b8d941c40/VepaySDK/Sources/UI/Vepay3DSController/Vepay3DSController.swift#L85C5-L119C6)

  

  

  

## Запланированные улучшения

  

  

### (Скоро) Можно будет сохранять и получать сохранённые карты

  

  

### (Скоро) Можно будет отсканировать карту используя камеру

  

  

### (Сейчас ресёрчиться) Возможность отсканировать карту через NFC

  

  

##  <a name="X-User"></a>Как получить X-User

  

X-User используется в header HTTP запроса и является методом авторизации в системе Vepay

  

  

### Для новых клиентов

  

1. Заполните на сайте

1. На сайте https://vepay.online/ заполняется заявка и отправляется нашим менеджерам

2. Менеджер обсуждает с клиентом доступные каналы и ставки и условия

3, Если клиент согласен, то менеджер запрашивает у клиента необходимые документы (в зависимости от  услуг которые необходимы) и направляет запрос в банк эквайер

4. Если банк эквайер согласен работать с клиентом, то заключается трехсторонний договор и банк выдает канал для работы

5. Клиенту выдается тестовый доступ к api и лк тех. поддержкой vepay, создается тех. чат и начинается процесс интеграции

6. Когда клиент завершит тестовую отладку на своей стороне, то ему на почту высылается архив с боевыми доступами где как раз присутствует X-User

  

### Для клиетов уже работающих с нами

  

Вы можете обратиться к менеджеру, для получения X-User
