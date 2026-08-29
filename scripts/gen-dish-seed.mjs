// One-time generator for the dish dictionary seed (migration 037 + seed.sql mirror).
// Run: node scripts/gen-dish-seed.mjs  (from repo root)
// Idempotent outputs: writes the migration file and appends/refreshes the
// mirror block in supabase/seed.sql between the markers below.
import fs from 'node:fs'

// Sourcing pass 2026-08-29: Wikimedia Commons lead images, hotlink-verified.
// Heavy originals (4-8 MB) are embedded as /thumb/ 1280px renditions.
// null = no qualifying Commons photo found (honest UI placeholder).
const PHOTOS = {
  'pho-bo': 'https://upload.wikimedia.org/wikipedia/commons/9/99/Ph%E1%BB%9F_b%C3%B2%2C_C%E1%BA%A7u_Gi%E1%BA%A5y%2C_H%C3%A0_N%E1%BB%99i.jpg',
  'pho-ga': 'https://upload.wikimedia.org/wikipedia/commons/f/f3/Vietnamsk%C3%A1_ku%C5%99ec%C3%AD_pol%C3%A9vka_%E2%80%9Cph%E1%BB%9F_g%C3%A0%E2%80%9C_se_%C5%A1irok%C3%BDmi_r%C3%BD%C5%BEov%C3%BDmi_nudlemi_01.JPG',
  'banh-mi': 'https://upload.wikimedia.org/wikipedia/commons/0/0c/B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng.png',
  'banh-xeo': 'https://upload.wikimedia.org/wikipedia/commons/5/59/Banh_Xeo_with_fish_sauce_and_vegetables.jpg',
  'banh-khoai': 'https://upload.wikimedia.org/wikipedia/commons/0/01/B%C3%A1nh_kho%C3%A1i.jpg',
  'bun-cha-ca': 'https://upload.wikimedia.org/wikipedia/commons/3/32/B%C3%BAn_ch%E1%BA%A3_c%C3%A1%2C_th%C3%A1ng_8_n%C4%83m_2018.JPG',
  'bun-cha': 'https://upload.wikimedia.org/wikipedia/commons/4/4d/B%C3%BAn_ch%E1%BA%A3_Vietnamese_food.jpg',
  'bun-bo-hue': 'https://upload.wikimedia.org/wikipedia/commons/0/04/B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_-_Ch%E1%BB%A3_%C4%90%C3%B4ng_Ba_%282024%29_-_img_02.jpg',
  'mi-quang': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg/1280px-M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg',
  'cao-lau': 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Cao_l%E1%BA%A7u_H%E1%BB%99i_An_%282024%29.jpg',
  'com-ga': 'https://upload.wikimedia.org/wikipedia/commons/8/89/C%C6%A1m_g%C3%A0_Tam_K%E1%BB%B3%2C_Qu%E1%BA%A3ng_Nam.JPG',
  'com-tam': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg/1280px-C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg',
  'hu-tieu': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Hu_Tieu_Nam_Vang.jpg',
  'banh-canh-cha-ca': null,
  'banh-canh-tom': 'https://upload.wikimedia.org/wikipedia/commons/d/d5/M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%281%29.jpg',
  'goi-cuon': 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Homemade_spring_rolls_%287010969349%29.jpg',
  'cha-gio': 'https://upload.wikimedia.org/wikipedia/commons/6/6b/Cha_gio.jpg',
  'nem-lui': 'https://upload.wikimedia.org/wikipedia/commons/8/88/Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%282%29.jpg',
  'banh-cuon': 'https://upload.wikimedia.org/wikipedia/commons/b/b2/B%C3%A1nh_cu%E1%BB%91n_Thanh_Tr%C3%AC.jpg',
  'banh-bao': 'https://upload.wikimedia.org/wikipedia/commons/8/80/B%C3%A1nh_bao.jpg',
  'xoi': 'https://upload.wikimedia.org/wikipedia/commons/f/f9/X%C3%B4i_x%C3%A9o.jpg',
  'chao-ga': 'https://upload.wikimedia.org/wikipedia/commons/2/26/Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%28t%C3%B4_g%C3%A0_x%C3%A9_phay%29_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg',
  'lau-thai': 'https://upload.wikimedia.org/wikipedia/commons/c/c6/MK_Suki_Siam_Square.jpg',
  'lau-ga': 'https://upload.wikimedia.org/wikipedia/commons/0/02/Newone_-_l%E1%BA%A9u_g%C3%A0%2C_s%C6%B0%E1%BB%9Dn_v%C3%A0_r%C6%B0%E1%BB%A3u_%C4%91inh_l%C4%83ng.jpg',
  'oc': 'https://upload.wikimedia.org/wikipedia/commons/f/f5/%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%281%29.JPG',
  'tom-nuong': 'https://upload.wikimedia.org/wikipedia/commons/a/ab/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%285%29.JPG',
  'ca-kho-to': 'https://upload.wikimedia.org/wikipedia/commons/b/b4/C%C3%A1_kho_t%E1%BB%99.JPG',
  'ga-xao-sa-ot': 'https://upload.wikimedia.org/wikipedia/commons/d/d8/Lemongrass_Chicken_%287491346796%29.jpg',
  'bo-luc-lac': 'https://upload.wikimedia.org/wikipedia/commons/7/78/Product_Shots_of_Food-Bo_Luc_Lac.jpg',
  'thit-nuong': null,
  'banh-trang-tron': 'https://upload.wikimedia.org/wikipedia/commons/6/63/Vietnamese_%22banh_trang_tron%22.JPG',
  'goi': 'https://upload.wikimedia.org/wikipedia/commons/9/9f/G%E1%BB%8Fi_%C4%91u_%C4%91%E1%BB%A7_kh%C3%B4_b%C3%B2.jpg',
  'ca-phe-sua-da': 'https://upload.wikimedia.org/wikipedia/commons/b/b7/Viet-coffee.jpg',
  'ca-phe-trung': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg/1280px-C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg',
  'bac-xiu': 'https://upload.wikimedia.org/wikipedia/commons/2/29/Ly_p%E1%BA%B7c_x%E1%BB%89u_s%E1%BB%AFa_%C4%91%C3%A1_%E1%BB%9F_Q1_ng18th8n2022.jpg',
  'tra-da': 'https://upload.wikimedia.org/wikipedia/commons/6/65/Qu%C3%A1n_m%C3%AC_qu%E1%BA%A3ng_Th%E1%BA%A3o_%E1%BB%9F_Q_T%C3%A2n_B%C3%ACnh_ng9th9n2022_%28ly_tr%C3%A0_%C4%91%C3%A1%29.jpg',
  'sinh-to': 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Sinh_t%E1%BB%91_b%C6%A1.jpg',
  'nuoc-mia': 'https://upload.wikimedia.org/wikipedia/commons/6/63/Sugarcanejuice.jpg',
  'nuoc-chanh': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Limeade.jpg',
  'bia': 'https://upload.wikimedia.org/wikipedia/commons/0/0a/Bia_hoi.jpg',
  'banh-flan': 'https://upload.wikimedia.org/wikipedia/commons/4/43/Homemade_Flan.jpg',
  'che': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ch%C3%A8_B%E1%BA%AFp.jpg/1280px-Ch%C3%A8_B%E1%BA%AFp.jpg',
  'kem': 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Kem_sua_dua_Trang_Tien.jpg',
  'banh-uot': 'https://upload.wikimedia.org/wikipedia/commons/3/3f/B%C3%A1nh_%C6%B0%E1%BB%9Bt.jpg',
  'mi-xao': null,
  'com-rang': 'https://upload.wikimedia.org/wikipedia/commons/e/e7/C%C6%A1m_rang.JPG',
  'canh-chua': 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Canhchua2.jpg',
  'tra-chanh': null,
  'nuoc-ep': 'https://upload.wikimedia.org/wikipedia/commons/f/fd/Orange_juice_1.jpg',
  'cha-ca': 'https://upload.wikimedia.org/wikipedia/commons/2/20/Ch%E1%BA%A3_c%C3%A1.jpg'
}

const D = [
  ['pho-bo', 'Phở bò', 'soup,noodle,beef', 'Фо бо', 'Рисовая лапша в говяжьем бульоне с говядиной и зеленью. Национальное блюдо - едят в любое время дня.', 'Pho bo', 'Rice noodles in beef broth with beef slices and herbs. The national dish - eaten any time of day.'],
  ['pho-ga', 'Phở gà', 'soup,noodle,chicken', 'Фо га', 'Тот же фо, но с курицей - бульон светлее и мягче. Хороший первый шаг во вьетнамские супы.', 'Pho ga', 'Pho with chicken - a lighter, gentler broth. A good first step into Vietnamese soups.'],
  ['banh-mi', 'Bánh mì', 'street,snack', 'Банх ми', 'Вьетнамский багет с мясом, паштетом и маринованными овощами. Хрустящий, дешёвый, удобно с собой.', 'Banh mi', 'Crispy Vietnamese baguette with meat, pate, and pickles. Cheap and perfect on the go.'],
  ['banh-xeo', 'Bánh xèo', 'street,pancake', 'Баншо', 'Хрустящий рисовый блинчик с креветкой или свининой - ешь руками, заворачивая в зелень.', 'Banh xeo', 'Crispy turmeric rice pancake with shrimp or pork - wrap it in herbs and eat by hand.'],
  ['banh-khoai', 'Bánh khoái', 'street,pancake', 'Бань хуай', 'Хуэская версия баншо: толще, с яйцом и свининой.', 'Banh khoai', 'Hue-style thicker banh xeo with egg and pork.'],
  ['bun-cha-ca', 'Bún chả cá', 'soup,noodle,fish', 'Бун ча ка', 'Лапша с рыбными фрикадельками - фирменный завтрак Дананга.', 'Bun cha ca', 'Noodle soup with fish cakes - Da Nang signature breakfast.'],
  ['bun-cha', 'Bún chả', 'noodle,pork,grill', 'Бун ча', 'Лапша с жареными свиными котлетами и травами - ханойская классика.', 'Bun cha', 'Grilled pork patties over rice noodles with herbs - a Hanoi classic.'],
  ['bun-bo-hue', 'Bún bò Huế', 'soup,noodle,spicy', 'Бун бо хуэ', 'Острый суп из Хюэ с говядиной и колбасками. Для любителей поострее.', 'Bun bo Hue', 'Spicy Hue-style beef noodle soup. For those who like heat.'],
  ['mi-quang', 'Mỳ Quảng', 'noodle,pork', 'Микуанг', 'Жёлтая рисовая лапша с минимальным количеством бульона - фирменное блюдо Дананга.', 'Mi Quang', 'Turmeric rice noodles with just a splash of broth - the signature dish of Da Nang.'],
  ['cao-lau', 'Cao lầu', 'noodle,pork', 'Каолау', 'Лапша Хойана со свининой и хрустящими сухариками.', 'Cao lau', 'Hoi An noodles with pork and crispy croutons.'],
  ['com-ga', 'Cơm gà', 'rice,chicken', 'Ком га', 'Рис с курицей - просто, сытно, беспроигрышный выбор.', 'Com ga', 'Chicken rice - simple, filling, always a safe choice.'],
  ['com-tam', 'Cơm tấm', 'rice,pork,grill', 'Ком там', 'Дроблёный рис со свининой на гриле и яйцом.', 'Com tam', 'Broken rice with a grilled pork chop and egg.'],
  ['hu-tieu', 'Hủ tiếu', 'soup,noodle', 'Ху тиу', 'Суп с прозрачной лапшой - лёгкая южная классика.', 'Hu tieu', 'Clear noodle soup - a light southern classic.'],
  ['banh-canh-cha-ca', 'Bánh canh chả cá', 'soup,fish', 'Бань кань ча ка', 'Густая рисовая лапша с рыбными котлетами.', 'Banh canh cha ca', 'Thick rice noodle soup with fish cakes.'],
  ['banh-canh-tom', 'Bánh canh tôm', 'soup,shrimp', 'Бань кань том', 'Та же густая лапша, но с креветками.', 'Banh canh tom', 'The same thick rice noodles with shrimp.'],
  ['goi-cuon', 'Gỏi cuốn', 'fresh,snack', 'Гой куон', 'Свежие спринг-роллы с креветкой и травами - лёгкая закуска.', 'Goi cuon', 'Fresh spring rolls with shrimp and herbs. Light and healthy.'],
  ['cha-gio', 'Chả giò', 'fried,snack', 'Ча зё', 'Жареные спринг-роллы - хрустящая классика уличной еды.', 'Cha gio', 'Crispy fried spring rolls - the crunchy street classic.'],
  ['nem-lui', 'Nem lụi', 'grill,street', 'Нем луй', 'Свининые шашлычки на лемонграссе - заворачивай в рисовую бумагу с зеленью.', 'Nem lui', 'Lemongrass pork skewers - wrap them in rice paper with herbs.'],
  ['banh-cuon', 'Bánh cuốn', 'fresh,snack', 'Бань куон', 'Тонкие паровые рисовые блинчики с фаршем - нежный завтрак.', 'Banh cuon', 'Delicate steamed rice rolls with minced pork.'],
  ['banh-bao', 'Bánh bao', 'snack', 'Бань бао', 'Паровой пирожок с фаршем и яйцом - быстрый перекус.', 'Banh bao', 'Steamed bun with pork and egg - a quick street snack.'],
  ['xoi', 'Xôi', 'rice,snack', 'Ксо', 'Клейкий рис с начинками - завтрак на бегу.', 'Xoi', 'Sticky rice with toppings - breakfast on the go.'],
  ['chao-ga', 'Cháo gà', 'soup,rice,chicken', 'Чао га', 'Рисовая каша с курицей - комфортная еда.', 'Chao ga', 'Chicken rice porridge - comfort food.'],
  ['lau-thai', 'Lẩu Thái', 'hotpot,spicy,group', 'Лау тай', 'Тайский хотпот на компанию - варишь сам за столом.', 'Lau Thai', 'Thai-style hotpot for a group - you cook it at the table.'],
  ['lau-ga', 'Lẩu gà', 'hotpot,chicken,group', 'Лау га', 'Куриный хотпот - мягче и дешевле тайского.', 'Lau ga', 'Chicken hotpot - milder and cheaper than the Thai one.'],
  ['oc', 'Ốc', 'seafood,snack,beer', 'Улитки', 'Улитки во всех видах - любимая пивная закуска у местных.', 'Snails', 'Snails every way - the local beer snack.'],
  ['tom-nuong', 'Tôm nướng', 'seafood,grill', 'Креветки на гриле', 'Креветки на углях - обычно продают на вес.', 'Grilled shrimp', 'Charcoal-grilled prawns - usually sold by weight.'],
  ['ca-kho-to', 'Cá kho tộ', 'fish,rice', 'Ка хо то', 'Карамелизированная рыба в глиняном горшочке. Бери с рисом.', 'Ca kho to', 'Caramelized fish in a clay pot. Order rice with it.'],
  ['ga-xao-sa-ot', 'Gà xào sả ớt', 'chicken,spicy', 'Курица с лемонграссом', 'Курица, обжаренная с лемонграссом и чили.', 'Lemongrass chicken', 'Chicken stir-fried with lemongrass and chili.'],
  ['bo-luc-lac', 'Bò lúc lắc', 'beef', 'Бо люк лак', 'Кубики говядины с луком, «трясёная говядина».', 'Shaking beef', 'Wok-tossed beef cubes with onion.'],
  ['thit-nuong', 'Thịt nướng', 'grill,pork', 'Свинина на гриле', 'Свинина на углях - основа многих блюд и роллов.', 'Grilled pork', 'Charcoal-grilled pork - the base of many dishes and rolls.'],
  ['banh-trang-tron', 'Bánh tráng trộn', 'street,snack', 'Салат из рисовой бумаги', 'Измельчённая рисовая бумага с приправами - уличный фастфуд молодёжи.', 'Rice paper salad', 'Shredded rice paper salad - street food for the young.'],
  ['goi', 'Gỏi', 'fresh,salad', 'Гой (салат)', 'Вьетнамский салат: папайя или морковь, арахис, креветки.', 'Vietnamese salad', 'Vietnamese salad: green papaya or carrot, peanuts, shrimp.'],
  ['ca-phe-sua-da', 'Cà phê sữa đá', 'coffee,drink', 'Кофе со сгущёнкой и льдом', 'Фильтр-кофе + сгущёнка + лёд. Крепко и сладко.', 'Iced milk coffee', 'Filter coffee with condensed milk over ice. Strong and sweet.'],
  ['ca-phe-trung', 'Cà phê trứng', 'coffee,drink', 'Яичный кофе', 'Кофе со взбитой яично-сгущённой пеной - ханойский десерт.', 'Egg coffee', 'Coffee with whipped egg-yolk custard foam - a Hanoi dessert.'],
  ['bac-xiu', 'Bạc xỉu', 'coffee,drink,sweet', 'Бак шиу', 'Почти молоко с каплей кофе - для тех, кто не любит горечь.', 'Bac xiu', 'Mostly milk with a splash of coffee - for the non-bitter crowd.'],
  ['tra-da', 'Trà đá', 'drink,free', 'Холодный чай', 'Бесплатный ледяной чай на каждом столе уличных заведений.', 'Iced tea', 'The free iced tea on every street-food table.'],
  ['sinh-to', 'Sinh tố', 'drink,fruit', 'Смузи', 'Фруктовый смузи, часто с йогуртом.', 'Smoothie', 'Fruit smoothie, often with yogurt.'],
  ['nuoc-mia', 'Nước mía', 'drink', 'Тростниковый сок', 'Свежевыжатый сок сахарного тростника.', 'Sugarcane juice', 'Fresh-pressed sugarcane juice.'],
  ['nuoc-chanh', 'Nước chanh', 'drink', 'Лаймовый лимонад', 'Сок лайма с сахаром и льдом.', 'Limeade', 'Lime juice with sugar and ice.'],
  ['bia', 'Bia', 'drink,beer', 'Пиво', 'Местное разливное («bia hơi») или бутылочное.', 'Beer', 'Local draft (bia hơi) or bottled beer.'],
  ['banh-flan', 'Bánh flan', 'dessert,sweet', 'Бан флан', 'Вьетнамский крем-карамель.', 'Flan', 'Vietnamese creme caramel.'],
  ['che', 'Chè', 'dessert,sweet', 'Че', 'Сладкий десерт из бобов, желе и кокосового молока.', 'Che', 'Sweet dessert soup with beans, jelly, and coconut milk.'],
  ['kem', 'Kem', 'dessert', 'Мороженое', 'Мороженое или фруктовый лёд.', 'Ice cream', 'Ice cream or fruit popsicles.'],
  ['banh-uot', 'Bánh ướt', 'fresh,snack', 'Бань уот', 'Мягкие паровые рисовые листы с начинкой.', 'Wet rice sheets', 'Soft steamed rice sheets with filling.'],
  ['mi-xao', 'Mỳ xào', 'noodle,fried', 'Жареная лапша', 'Лапша, обжаренная с мясом или морепродуктами.', 'Fried noodles', 'Stir-fried noodles with meat or seafood.'],
  ['com-rang', 'Cơm rang', 'rice,fried', 'Жареный рис', 'Жареный рис с добавками (thập cẩm - ассорти).', 'Fried rice', 'Fried rice with mix-ins (thap cam = mixed).'],
  ['canh-chua', 'Canh chua', 'soup,sour,fish', 'Кань чуа', 'Кислый суп с рыбой и ананасом - южная классика.', 'Sour soup', 'Tamarind sour soup with fish and pineapple - a southern classic.'],
  ['tra-chanh', 'Trà chanh', 'drink,cheap', 'Лимонный чай', 'Лайм + зелёный чай + лёд - любимый напиток молодёжи.', 'Lemon tea', 'Lime plus green tea plus ice - the youth favorite.'],
  ['nuoc-ep', 'Nước ép', 'drink,fruit', 'Свежевыжатый сок', 'Соки из свежих фруктов: манго, арбуз, ананас.', 'Fresh juice', 'Fresh-pressed juices: mango, watermelon, pineapple.'],
  ['cha-ca', 'Chả cá', 'fish,grill', 'Ча ка', 'Рыба, обжаренная с укропом и куркумой.', 'Turmeric fish', 'Fish sauteed with dill and turmeric.'],
]

const esc = s => s.replace(/'/g, "''")
const hex = n => n.toString(16).padStart(2, '0')
const id = n => `d15ef00d-4a2b-4c9d-8e1f-0000000000${hex(n)}`
const sq = (s) => `'${esc(s)}'`
const photoLit = (slug) => {
  const url = PHOTOS[slug]
  return url ? `'${esc(url)}'` : 'null'
}

let places = '', locs = ''
D.forEach((d, i) => {
  const [slug, vi, tags, ruName, ruSum, enName, enSum] = d
  const tagsLit = `'{{{${tags}}}}'`.replace('{{{', '{').replace('}}}', '}')
  places += `\t('${id(i + 1)}', ${sq(slug)}, ${sq(vi)}, ${photoLit(slug)}, ${tagsLit}, false, 'published'),\n`
  locs += `\t('${id(i + 1)}', 'ru', ${sq(ruName)}, ${sq(ruSum)}),\n`
  locs += `\t('${id(i + 1)}', 'en', ${sq(enName)}, ${sq(enSum)}),\n`
})
places = places.replace(/,\n$/, '\n')
locs = locs.replace(/,\n$/, '\n')

const migration = `-- Migration: 037_dish_dictionary_seed
-- Purpose: Menu translator Phase A seed (spec: vault/wiki/architecture/menu-translator-spec.md).
-- 50 canonical Vietnamese dishes (global dictionary, not venue-specific):
-- names/summaries are general culinary knowledge; photo_url is sourced from
-- Wikimedia Commons (46/50, hotlink-verified; heavy originals embedded as
-- 1280px thumbs). null photos render an honest UI placeholder. Entries ship
-- published but verified=false: curation flips that in Phase B. Mirrored
-- into seed.sql.

insert into public.dishes (id, slug, name_vi, photo_url, tags, verified, status)
values
${places}
on conflict (slug) do update
set
	name_vi = excluded.name_vi,
	photo_url = excluded.photo_url,
	tags = excluded.tags,
	status = excluded.status;

insert into public.dish_localizations (dish_id, language, name, summary)
values
${locs}
on conflict (dish_id, language) do update
set
	name = excluded.name,
	summary = excluded.summary;
`

fs.writeFileSync('supabase/migrations/20260829130000_037_dish_dictionary_seed.sql', migration)

const beginMark = '-- BEGIN dish dictionary seed (migration 037 mirror; generated)'
const endMark = '-- END dish dictionary seed'
const seed = fs.readFileSync('supabase/seed.sql', 'utf8')
const clean = seed.replace(new RegExp(beginMark + '[\\s\\S]*?' + endMark + '\\n?', 'g'), '').trimEnd()
const mirror = `\n\n${beginMark}\n${migration.split('\n').slice(4).join('\n')}\n${endMark}\n`
fs.writeFileSync('supabase/seed.sql', clean + mirror)

console.log('migration 037 written; seed.sql mirror refreshed; dishes:', D.length)
