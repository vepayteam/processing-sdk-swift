# ``VepaySDK``

Библиотека позволяет проводить трансграничные переводы, основываясь на технологиях Vepay



## Начало работы


### Авторизация

Для работы с SDK вам потребуется X-User, для авторизации
По вопросу с получением, вы можете обратиться к секции [Как получить X-User](#X-User)


### Подключение

Вы можете подключить через клонирование или CocoaPods
https://github

Подключение через CocoaPods:
pod 'VepaySDK', :git => "https://github"

Библиотека работает на iOS 12 и выше



## Запросы


### Последоватольность

1. Вначале вам нужно [создать счёт](#Cоздание), в ответ получаете VepayInvoice с uuid
2. Используя этот uuid, вы [оплачиваете счёт](#Оплата)
3. Установите SSE соединение, для получение обновления статуса платежа
4. Если потребуется, [пройдите 3DS](#3DS)


### H2H


#### <a name="Cоздание"></a>[Cоздание Счёта](#https://test.vepay.online/h2hapi/v1#/default/post_invoices)
При создании инвойса вам понадобиться указать externalID: String, вы можете это сделать используя UUID().uuidString
> В ответ вы получаете [VepayInvoice](#VepayInvoice) в котором будет два идентификатора счёта 
- uuid - Главный идентификатор, с ним работают все запросы
- id - Является устаревшим

VepayInvoiceCreate([invoice: VepayInvoice](#VepayInvoice), [xUser: String](#User))


#### <a name="Созданный"></a>[Получить Объект Счёта](#https://test.vepay.online/h2hapi/v1#/default/get_invoices__id_)
> Возращает счёт по его иднетификатору

VepayInvoiceGet([uuid: String](#Cоздание), [xUser: String](#User))


#### <a name="Оплата"></a>[Сделать Оплату Счёта](#https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment)
Используя идентификатор (uuid или id) созданного счёта проводит оплату
В параметре form, вам понадобиться ввести размеры экрана в котором будет отображаться 3DS, размеры WebView 

> В ответ вы получаете [VepayPaymentResponse](#VepayPaymentResponse), в котором указывается нужно ли проводит 3DS
Вы можете использовать enum readable, для удобного просмотра ответа

VepayInvoicePayment([uuid: String](#Cоздание), [form: VepayPayment](#VepayPayment), [xUser: String](#User))

VepayInvoicePayment([invoice: VepayInvoice](#VepayInvoice), [form: VepayPayment](#VepayPayment), [xUser: String](#User))

VepayInvoicePayment([invoice: VepayInvoice](#VepayInvoice), card: VepayPaymentCard, specificIPVersion: VepayUtils.IPVersion?, size: CGSize, [xUser: String](#User))


#### <a name="Оплаченный"></a>[Получить Объект Оплаты](#https://test.vepay.online/h2hapi/v1#/default/get_invoices__id__payment)
> Возращает объект оплаты, в котором, если есть, будут указаны данные для проведения 3DS
> Status: 
    OK - готов к 3DS'у
    PENDING - нужно повторить оплату

VepayInvoiceGetPayment([uuid: String](#Cоздание), [xUser: String](#User))


#### <a name="3DS"></a>Выполнить 3DS
Данные для 3DS'a получается в ответе оплаты, в объекте VepayPaymentResponse.Redirect

Для проведения 3DS вам понадобиться:
- url (для перенаправления): 
    Если PENDING, то nil
    Например https://some-access-control-server.com/3ds?payId=123
- method (HTTP Method, может быть POST или GET):
    Если POST, нужно добавить url и postParameters
    Если PENDING, то nil
- postParameters:
    Если status == "PENDING" или method == "GET", то nil
    Например [
        "pa_req": "K8QufpC0UQXOoYcNlfT857Tvu15Wli12WXyvCyTX8AKY2QyMUCk",
        "md": "YcNlfT857Tvu15Wli12WXyvCyTX8AKY2QyMUCkGMifQ==",
        "term_url": "https://api.vepay.online/pay/orderdone/12345"
    ]

VepayMake3DS(url: String, method: String, postParameters: [String: String]?)


#### <a name="Возрат"></a>[Сделать Возрат Средств](#https://test.vepay.online/h2hapi/v1#/default/post_invoices__id__payment_refunds)

VepayInvoiceRefund([uuid: String](#Cоздание), amount: Int, [xUser: String](#User))


#### <a name="Возращённый"></a>[Получить Объект Возрата Средств](#https://test.vepay.online/h2hapi/v1#/default/get_invoices__id__payment)

VepayInvoiceRefundGet([uuid: String](#Cоздание), [xUser: String](#User))


#### <a name="Отмена"></a>[Сделать Отмену Платежа](#https://test.vepay.online/h2hapi/v1#/default/put_invoices__id__payment_reversed)

VepayInvoiceCancel([uuid: String](#Cоздание), [xUser: String](#User))


### Handy Trick

Есть 2 способа выполнения запроса:
- Через метод класса VepayBaseRequest
func request(
    sessionHandler: VepaySessionHandler,
    completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void)
Так же каждый запрос соответсвует протоколу VepayRequest

- Через метод протокола VepayRequest
request(
    sessionHandler: VepaySessionHandler,
    success: @escaping (ResponseType) -> Void,
    error: @escaping (VepayError) -> Void)

В методе вы можете оверрайднуть параметр sessionHandler, на свой объект менеджер запросов, соответсвующий протоколу VepayDefaultSession


## Запланированные улучшения

### (Скоро) Можно будет сохранять и получать сохранённые карты

### (Скоро) Можно будет отсканировать карту используя камеру

### (Скоро) Улучшение кастомизирования UI

### (Предполагается) SSE вынеситься в отдельню библиотеку, чтобы можно было использовать её как stand-alone library

### (Сейчас ресёрчиться) Возможность отсканировать карту через NFC



## <a name="User"></a>Как получить X-User


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
