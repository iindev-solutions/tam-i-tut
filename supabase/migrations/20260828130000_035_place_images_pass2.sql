-- Migration: 035_place_images_pass2
-- Purpose: second photo-sourcing pass (same day as 034) - the 9 venues that
-- stayed null there. Sources: Wayback Machine og:image extraction for the
-- bot-blocked Michelin Guide pages and the JS-rendered Burger Bros site,
-- wp-content extraction from the Vietnamese guides already used for venue
-- sourcing (ghiendanang.com, kalakalabeachclub.com, hoiandaytrip.com), and
-- the venue's own site CDN (RIONI via its Trip.com review cover). Every URL
-- verified to return a JPEG with no referer. Mirrored into seed.sql.

update public.places set image_url = 'https://hoiandaytrip.com/wp-content/uploads/2025/12/madam-khanh-1.jpg' where slug = 'banh-mi-madam-khanh';
update public.places set image_url = 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/70695ae344e74b7ba42c132cca61ca84.jpeg?width=1000' where slug = 'be-man-seafood';
update public.places set image_url = 'https://hoiandaytrip.com/wp-content/uploads/2024/11/an-thuong-tourist-street-da-nang.jpg' where slug = 'an-thuong-street';
update public.places set image_url = 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/8e802149bbea41adb30f5fb446eddb2f.jpeg?width=1000' where slug = 'mi-quang-sua-hong-van';
update public.places set image_url = 'https://prod-pics.guide.michelin.com/api/public/content/68cd514ddf784deca07fd6fbb910c825.jpeg?format=jpeg&w=1000&h=1000' where slug = 'com-ga-lan';
update public.places set image_url = 'https://ghiendanang.com/wp-content/uploads/2025/06/nhang-nuong-1.jpg' where slug = 'nhang-nuong';
update public.places set image_url = 'https://kalakalabeachclub.com/wp-content/uploads/2026/06/local-street-food-in-da-nang-7.jpg' where slug = 'be-loan';
update public.places set image_url = 'https://cdn.amebaowndme.com/madrid-prd/madrid-web/images/sites/55475/42a6424c88e80d47ab397b4beba5ca5e_dad62fbef639e5318e5aed87c84d48f0.jpg' where slug = 'burger-bros';
update public.places set image_url = 'https://ak-d.tripcdn.com/images/1mi1v224x99ckzi9c865E_R_600_400_R5_Q90.jpg?proc=source/trip' where slug = 'rioni-georgian';
