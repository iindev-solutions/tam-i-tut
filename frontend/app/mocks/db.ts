import type { MockDb } from '~/types/content'

export const mockDb: MockDb = {
  cities: [
    { id: 'da-nang', labelKey: 'cities.daNang', countryKey: 'cities.vietnam', flag: '🇻🇳', active: true },
    { id: 'nha-trang', labelKey: 'cities.nhaTrang', countryKey: 'cities.vietnam', flag: '🇻🇳', active: false },
    { id: 'pattaya', labelKey: 'cities.pattaya', countryKey: 'cities.thailand', flag: '🇹🇭', active: false },
    { id: 'phuket', labelKey: 'cities.phuket', countryKey: 'cities.thailand', flag: '🇹🇭', active: false }
  ],

  categories: [
    { id: 'housing', labelKey: 'home.housing', icon: 'i-lucide-house', to: '/categories/housing', countKind: 'districts' },
    { id: 'food', labelKey: 'home.food', icon: 'i-lucide-utensils', to: '/categories/food', countKind: 'places' },
    { id: 'transport', labelKey: 'home.transport', icon: 'i-lucide-bike', to: '/categories/transport', countKind: 'guides', guideCategory: 'transport' },
    { id: 'money', labelKey: 'home.money', icon: 'i-lucide-wallet', to: '/categories/money', countKind: 'guides', guideCategory: 'money' },
    { id: 'safety', labelKey: 'home.safety', icon: 'i-lucide-shield-check', to: '/categories/safety', countKind: 'guides', guideCategory: 'safety' },
    { id: 'culture', labelKey: 'home.culture', icon: 'i-lucide-book-open', to: '/categories/culture', countKind: 'none' }
  ],

  places: [
    {
      id: 'banh-mi-madam-khanh',
      slug: 'banh-mi-madam-khanh',
      name: 'Bánh mì Madam Khanh',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Hải Châu, Trần Cao Vân', en: 'Hai Chau, Tran Cao Van' },
      summary: {
        ru: 'Банхми с начинками на выбор, 25-40 тыс. ₫. Работает с раннего утра, очередь к вечеру.',
        en: 'Banh mi with fillings to pick, 25-40k VND. Opens early, expect a queue in the evening.'
      },
      imageUrl: 'https://hoiandaytrip.com/wp-content/uploads/2025/12/madam-khanh-1.jpg',
      verified: true,
      status: 'published',
      updated: '2026-08-12'
    },
    {
      id: 'mi-quang-1a',
      slug: 'mi-quang-1a',
      name: 'Mì Quang 1A',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Thanh Khê, 1A Hải Phòng', en: 'Thanh Khe, 1A Hai Phong' },
      summary: {
        ru: 'Мискуанг - фирменный суп Дананга с рисовой лапшой и креветкой. 35-60 тыс. ₫.',
        en: 'Mi quang - Da Nang signature rice noodle soup with shrimp. 35-60k VND.'
      },
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/df/Mi_Quang_1A_Danang.jpg',
      verified: true,
      status: 'published',
      updated: '2026-08-10'
    },
    {
      id: 'banh-xeo-ba-duong',
      slug: 'banh-xeo-ba-duong',
      name: 'Bánh xèo Bà Dưỡng',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Hải Châu, Hoàng Diệu', en: 'Hai Chau, Hoang Dieu' },
      summary: {
        ru: 'Хрустящие баншо с зеленью и арахисовым соусом. Легендарное место, 40-70 тыс. ₫.',
        en: 'Crispy banh xeo pancakes with herbs and peanut sauce. A local legend, 40-70k VND.'
      },
      imageUrl: 'https://mia.vn/media/uploads/blog-du-lich/thoa-man-voi-banh-xeo-ba-duong-ngon-nhat-da-nang-1636651211.jpg',
      verified: true,
      status: 'published',
      updated: '2026-08-14'
    },
    {
      id: 'bun-cha-ca-ba-lu',
      slug: 'bun-cha-ca-ba-lu',
      name: 'Bún chả cá Bà Lữ',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Hải Châu, центр', en: 'Hai Chau, city center' },
      summary: {
        ru: 'Рыбный суп бунчакка - завтрак местных. Идти до обеда, дальше закрывается. 30-50 тыс. ₫.',
        en: 'Fish cake noodle soup - a local breakfast. Go before noon, it closes after. 30-50k VND.'
      },
      imageUrl: 'https://danangbest.com/upload_content/bun-cha-ca-da-nang-3.webp',
      verified: true,
      status: 'published',
      updated: '2026-08-09'
    },
    {
      id: 'cho-con',
      slug: 'cho-con',
      name: 'Chợ Cồn',
      type: 'market',
      priceLevel: 'budget',
      area: { ru: 'Hải Châu, Ông Ích Khiêm', en: 'Hai Chau, Ong Ich Khiem' },
      summary: {
        ru: 'Главный рынок города: фудкорт наверху, фрукты и хозяйственное внизу. Только наличные.',
        en: 'The main city market: food court upstairs, fruit and goods below. Cash only.'
      },
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/1d/Con_Market_at_sunset.jpg',
      verified: true,
      status: 'published',
      updated: '2026-08-08'
    },
    {
      id: 'cho-han',
      slug: 'cho-han',
      name: 'Chợ Hàn',
      type: 'market',
      priceLevel: 'budget',
      area: { ru: 'Hải Châu, Trần Phú', en: 'Hai Chau, Tran Phu' },
      summary: {
        ru: 'Рынок у набережной реки Хан. Фрукты, кофе, сухофрукты - цены ниже туристических.',
        en: 'Market by the Han river promenade. Fruit, coffee, dried fruit - cheaper than tourist spots.'
      },
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/9b/Han_Market_Da_Nang.JPG',
      verified: true,
      status: 'published',
      updated: '2026-08-07'
    },
    {
      id: 'highlands-beach',
      slug: 'highlands-beach',
      name: 'Highlands Coffee (Võ Nguyên Giáp)',
      type: 'cafe',
      priceLevel: 'average',
      area: { ru: 'Sơn Trà, пляжная линия', en: 'Son Tra, beachfront' },
      summary: {
        ru: 'Сетка кофеен прямо у пляжа Mỹкхе. Кофе 45-75 тыс. ₫, карта принимают, Wi-Fi.',
        en: 'Chain cafe right on My Khe beach. Coffee 45-75k VND, cards accepted, Wi-Fi.'
      },
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Highlands_Coffee_storefront_DN.JPG',
      verified: true,
      status: 'published',
      updated: '2026-08-13'
    },
    {
      id: 'cong-cafe',
      slug: 'cong-cafe',
      name: 'Cộng Cà Phê (Bạch Đằng)',
      type: 'cafe',
      priceLevel: 'average',
      area: { ru: 'Hải Châu, набережная', en: 'Hai Chau, riverside' },
      summary: {
        ru: 'Кофейня в ретро-стиле с видом на реку Хан и мост Дракона. Есть розетки.',
        en: 'Retro-style cafe with Han river and Dragon Bridge views. Power sockets available.'
      },
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/67/C%E1%BB%99ng_C%C3%A0_Ph%C3%AA_coffee_milk.jpg',
      verified: false,
      status: 'published',
      updated: '2026-08-06'
    },
    {
      id: 'be-man-seafood',
      slug: 'be-man-seafood',
      name: 'Bé Mặn Seafood',
      type: 'restaurant',
      priceLevel: 'above',
      area: { ru: 'Ngũ Hành Sơn, Võ Nguyên Giáp', en: 'Ngu Hanh Son, Vo Nguyen Giap' },
      summary: {
        ru: 'Морепродукты с витрины: вес подтверждают при тебе. 150-400 тыс. ₫ за блюдо.',
        en: 'Seafood from the display: weight confirmed in front of you. 150-400k VND per dish.'
      },
      imageUrl: 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/70695ae344e74b7ba42c132cca61ca84.jpeg?width=1000',
      verified: true,
      status: 'published',
      updated: '2026-08-11'
    },
    {
      id: 'an-thuong-street',
      slug: 'an-thuong-street',
      name: 'An Thượng food street',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Sơn Trà, улица An Thượng', en: 'Son Tra, An Thuong street' },
      summary: {
        ru: 'Пешеходная улица еды в двух кварталах от моря: гриль, смузи, кофе до поздна.',
        en: 'Pedestrian food street two blocks from the sea: grills, smoothies, late-night coffee.'
      },
      imageUrl: 'https://hoiandaytrip.com/wp-content/uploads/2024/11/an-thuong-tourist-street-da-nang.jpg',
      verified: false,
      status: 'published',
      updated: '2026-08-15'
    }
  ],

  guides: [
    {
      id: 'transport-grab',
      category: 'transport',
      icon: 'i-lucide-car-taxi-front',
      title: { ru: 'Grab и Xanh SM', en: 'Grab and Xanh SM' },
      note: { ru: 'байк 15-30 тыс. ₫, авто 40-80 тыс. ₫', en: 'bike 15-30k, car 40-80k VND' },
      summary: {
        ru: 'Такси через приложение: цена известна заранее, оплата картой или наличными. Из аэропорта до центра 100-150 тыс. ₫.',
        en: 'App taxis: price fixed before the ride, pay by card or cash. Airport to center is 100-150k VND.'
      },
      status: 'published'
    },
    {
      id: 'transport-bike',
      category: 'transport',
      icon: 'i-lucide-bike',
      title: { ru: 'Аренда байка', en: 'Bike rental' },
      note: { ru: 'от 900 000 - 1 500 000 ₫ в месяц', en: '900,000-1,500,000 VND per month' },
      summary: {
        ru: 'Депозит 1-3 млн ₫ или паспорт. Проверь тормоза и свет, сфотографируй царапины до подписания.',
        en: 'Deposit 1-3M VND or a passport. Check brakes and lights, photograph scratches before signing.'
      },
      status: 'published'
    },
    {
      id: 'transport-bus',
      category: 'transport',
      icon: 'i-lucide-bus',
      title: { ru: 'Городские автобусы', en: 'City buses' },
      note: { ru: '5 000-10 000 ₫ за поездку', en: '5,000-10,000 VND per ride' },
      summary: {
        ru: 'Маршруты идут вдоль пляжной линии и через центр. Оплата наличными при входе, кондиционер есть.',
        en: 'Routes run along the beach line and through the center. Pay cash on boarding, air-con included.'
      },
      status: 'published'
    },
    {
      id: 'transport-airport',
      category: 'transport',
      icon: 'i-lucide-plane-landing',
      title: { ru: 'Из аэропорта', en: 'From the airport' },
      note: { ru: 'аэропорт в 3 км от центра', en: 'airport is 3 km from the center' },
      summary: {
        ru: 'Аэропорт внутри города: до центра 10 минут на Grab. Стойка такси дороже приложения.',
        en: 'The airport sits inside the city: 10 minutes to the center by Grab. The taxi desk costs more than the app.'
      },
      status: 'published'
    },
    {
      id: 'money-cash',
      category: 'money',
      icon: 'i-lucide-banknote',
      title: { ru: 'Наличные', en: 'Cash' },
      note: { ru: 'вьетнамский донг - основная валюта', en: 'Vietnamese dong is the main currency' },
      summary: {
        ru: 'Рынки, уличная еда и автобусы - только наличные. Держи мелкие купюры отдельно от крупных.',
        en: 'Markets, street food, and buses are cash only. Keep small bills separate from large ones.'
      },
      status: 'published'
    },
    {
      id: 'money-card',
      category: 'money',
      icon: 'i-lucide-credit-card',
      title: { ru: 'Карты', en: 'Cards' },
      note: { ru: 'Visa и Mastercard', en: 'Visa and Mastercard' },
      summary: {
        ru: 'Принимают в ТЦ, сетевых кафе и аптеках. В маленьких quánах и на рынках - нет.',
        en: 'Accepted in malls, chain cafes, and pharmacies. Not in small family shops or markets.'
      },
      status: 'published'
    },
    {
      id: 'money-qr',
      category: 'money',
      icon: 'i-lucide-qr-code',
      title: { ru: 'Оплата по QR', en: 'QR payments' },
      note: { ru: 'VietQR - везде у местных', en: 'VietQR - used by locals everywhere' },
      summary: {
        ru: 'В ресторанах часто принимают перевод по QR через местное банковское приложение. Туристу удобнее наличные или Grab.',
        en: 'Restaurants often take QR transfers via local bank apps. For visitors, cash or Grab is simpler.'
      },
      status: 'published'
    },
    {
      id: 'money-atm',
      category: 'money',
      icon: 'i-lucide-landmark',
      title: { ru: 'Банкоматы', en: 'ATMs' },
      note: { ru: 'лимит 2-5 млн ₫, комиссия 22-55 тыс. ₫', en: '2-5M VND limit, 22-55k VND fee' },
      summary: {
        ru: 'Снимай в банкоматах при отделениях Vietcombank или Techcombank: комиссия ниже, лимит выше.',
        en: 'Withdraw at Vietcombank or Techcombank branch ATMs: lower fees, higher limits.'
      },
      status: 'published'
    },
    {
      id: 'money-transfer',
      category: 'money',
      icon: 'i-lucide-send',
      title: { ru: 'Переводы', en: 'Transfers' },
      note: { ru: 'Wise и переводы по номеру карты', en: 'Wise and card-to-card transfers' },
      summary: {
        ru: 'Для оплаты аренды и крупных сумм. Курс уточняй в приложении до отправки.',
        en: 'For rent and large amounts. Check the rate in the app before sending.'
      },
      status: 'draft'
    },
    {
      id: 'safety-helmet',
      category: 'safety',
      icon: 'i-lucide-hard-hat',
      title: { ru: 'Шлем на байке', en: 'Helmet on a bike' },
      note: { ru: 'штраф до 600 000 ₫', en: 'fine up to 600,000 VND' },
      summary: {
        ru: 'Шлем обязателен для водителя и пассажира. Проверки на дорогах - обычное дело, без шлема штрафуют.',
        en: 'A helmet is required for rider and passenger. Road checks are routine; no helmet means a fine.'
      },
      status: 'published'
    },
    {
      id: 'safety-numbers',
      category: 'safety',
      icon: 'i-lucide-phone',
      title: { ru: 'Номера заранее', en: 'Numbers in advance' },
      note: { ru: 'доступны офлайн', en: 'available offline' },
      summary: {
        ru: 'Сохрани 113, 114 и 115 до первой поездки. Местные вызовы работают без интернета.',
        en: 'Save 113, 114, and 115 before your first ride. Local calls work without internet.'
      },
      status: 'published'
    },
    {
      id: 'safety-bags',
      category: 'safety',
      icon: 'i-lucide-backpack',
      title: { ru: 'Сумки на виду', en: 'Bags in sight' },
      note: { ru: 'не вешай на плечо к дороге', en: 'do not hang it road-side' },
      summary: {
        ru: 'Держи сумку дальше от проезжей части: мото-кражи сумок редки, но случаются вечером.',
        en: 'Keep your bag away from the road: moto bag-snatching is rare but happens at night.'
      },
      status: 'published'
    }
  ],

  contacts: [
    { id: 'police', number: '113', label: { ru: 'Полиция', en: 'Police' } },
    { id: 'fire', number: '114', label: { ru: 'Пожарная служба', en: 'Fire department' } },
    { id: 'ambulance', number: '115', label: { ru: 'Скорая помощь', en: 'Ambulance' } }
  ],

  reviews: [],

  activity: []
}
