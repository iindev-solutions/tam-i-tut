-- Migration: 034_place_images
-- Purpose: Phase 4 UI pass - venue photos. Adds a nullable `image_url` to
-- places and fills it with externally sourced, hotlink-verified photo URLs
-- (Wikimedia Commons, official sites, blog/CDN files verified to return an
-- image with no referer; no Tripadvisor/Foody/Google hotlinks - they block or
-- expire). `null` is the norm: the UI renders a styled type-icon placeholder
-- whenever the URL is missing or fails to load.

alter table public.places add column if not exists image_url text;

-- Sourced photo URLs (14 of 23 venues; sourcing pass 2026-08-28, idempotent).
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/d/df/Mi_Quang_1A_Danang.jpg' where slug = 'mi-quang-1a';
update public.places set image_url = 'https://mia.vn/media/uploads/blog-du-lich/thoa-man-voi-banh-xeo-ba-duong-ngon-nhat-da-nang-1636651211.jpg' where slug = 'banh-xeo-ba-duong';
update public.places set image_url = 'https://danangbest.com/upload_content/bun-cha-ca-da-nang-3.webp' where slug = 'bun-cha-ca-ba-lu';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/1d/Con_Market_at_sunset.jpg' where slug = 'cho-con';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9b/Han_Market_Da_Nang.JPG' where slug = 'cho-han';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Highlands_Coffee_storefront_DN.JPG' where slug = 'highlands-beach';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/6/67/C%E1%BB%99ng_C%C3%A0_Ph%C3%AA_coffee_milk.jpg' where slug = 'cong-cafe';
update public.places set image_url = 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/adc7acfaa0c04ac4ac201d3bcadc81e1.jpeg' where slug = 'bun-cha-ca-ba-hoa';
update public.places set image_url = 'https://cdn3.ivivu.com/2022/08/bun-mam-ba-dong-ivivu-3.jpg' where slug = 'bun-mam-ba-dong';
update public.places set image_url = 'https://mia.vn/media/uploads/blog-du-lich/mi-quang-ech-bep-trang-mon-ngon-ngo-cuong-khi-den-da-nang-1637316606.jpg' where slug = 'mi-quang-ech-bep-trang';
update public.places set image_url = 'https://vietnamlife.asia/wp-content/uploads/2024/09/Front-entrance-to-Indian-Restaurant-Ganesh-Da-Nang.jpg' where slug = 'ganesh-da-nang';
update public.places set image_url = 'https://www.pizzacardi.com/templates/yootheme/cache/a0/home-gallery-05-a0b66d50.jpeg' where slug = 'cardi-pizzeria';
update public.places set image_url = 'https://xliiicoffee.com/wp-content/uploads/2023/06/202306060712-43-factory-coffee-roaster-da-nang-vietnam-08.jpeg' where slug = 'xliii-coffee';
update public.places set image_url = 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg1aQLnSUfqLxZpx7s_VmHJxM_p9mlNSDv093GKJUrDJ8d5koGnPIqVQWvdfnN-d-yv5zk2cPofgC1m5KF2vTnitAoWBtX_P8lKDcX2eTKt_yzFILaRdnS4xiYqHk0QsTqrKlRry1krNxqg50F037KsFle9nrMRH6RGgz4P21XFe06LaPl2nHug/s1640/09%20TWN_5807%20B%C3%A1nh%20M%C3%AC%20C%C3%B4%20Ti%C3%AAn%20@%20Da%20Nang%20in%20Vietnam.JPG' where slug = 'banh-mi-co-tien';

-- Venues intentionally left null (no qualifying photo found during sourcing):
-- banh-mi-madam-khanh, be-man-seafood, an-thuong-street, mi-quang-sua-hong-van,
-- com-ga-lan, nhang-nuong, be-loan, burger-bros, rioni-georgian.
