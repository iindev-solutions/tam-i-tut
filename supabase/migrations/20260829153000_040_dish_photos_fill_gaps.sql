-- Migration: 040_dish_photos_fill_gaps
-- Purpose: founder decision - for the dish dictionary, a representative
-- photo beats an honest placeholder ("want to know how it looks"). These 4
-- dishes had no exact-variant photo in pass 1/2; they now get
-- representative Wikimedia Commons shots (broad dish family is acceptable).
-- Mirrored into seed.sql via scripts/gen-dish-seed.mjs.

update public.dishes set photo_url = 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Banh-Canh-Noodle-Soup.jpg' where slug = 'banh-canh-cha-ca';
update public.dishes set photo_url = 'https://upload.wikimedia.org/wikipedia/commons/4/47/Bun_thit_nuong.jpg' where slug = 'thit-nuong';
update public.dishes set photo_url = 'https://upload.wikimedia.org/wikipedia/commons/e/ee/M%C3%AC_x%C3%A0o_tr%E1%BB%A9ng_%E1%BB%9F_B%C3%ACnh_T%C3%A2n_ng%C3%A0y_29_th%C3%A1ng_3_n%C4%83m_2020_%281%29.jpg' where slug = 'mi-xao';
update public.dishes set photo_url = 'https://upload.wikimedia.org/wikipedia/commons/8/81/Lemon_Iced_Tea_1.JPG' where slug = 'tra-chanh';
