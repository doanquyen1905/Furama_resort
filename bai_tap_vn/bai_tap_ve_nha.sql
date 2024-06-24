--	Hiển thị thông tin của tất cả nhân viên có trong hệ thống có tên bắt đầu là một trong các ký tự “H”, “T” hoặc “K” và có tối đa 15 ký tự.--
use furamas_resorts;
select nhan_vien.ma_nhan_vien, nhan_vien.ho_ten from nhan_vien
where
    (nhan_vien.ho_ten LIKE 'H%'    -- Tên bắt đầu bằng 'H'


   OR nhan_vien.ho_ten LIKE 'T%'    -- Tên bắt đầu bằng 'T'

OR nhan_vien.ho_ten LIKE 'K%')   -- Tên bắt đầu bằng 'K'  -- Tên bắt đầu bằng 'H', 'T', hoặc 'K'
  AND LENGTH(nhan_vien.ho_ten) <= 15;

--	Hiển thị thông tin của tất cả khách hàng có độ tuổi từ 18 đến 50 tuổi và có địa chỉ ở “Đà Nẵng” hoặc “Quảng Trị”.--

select khach_hang.ma_khach_hang, khach_hang.ho_ten from khach_hang
where (ngay_sinh between '1974-6-20' and '2006-6-20') and (dia_chi like '%Đà Nẵng' or dia_chi like '%Quảng Trị');

--	Đếm xem tương ứng với mỗi khách hàng đã từng đặt phòng bao nhiêu lần. Kết quả hiển thị được sắp xếp tăng dần theo số lần đặt phòng của khách hàng.
 -- Chỉ đếm những khách hàng nào có Tên loại khách hàng là “Diamond”--

select kh.ma_khach_hang, kh.ho_ten,COUNT(hd.ma_hop_dong) AS So_Lan_Dat_Phong from khach_hang kh
join hop_dong hd on kh.ma_khach_hang = hd.ma_khach_hang
join loai_khach lk on kh.ma_loai_khach = lk.ma_loai_khach
where lk.ten_loai_khach = 'diamond'
group by kh.ma_khach_hang, kh.ho_ten
order by so_lan_dat_phong asc;

   -- Hiển   thị  IDKhachHang,   HoTen,   TenLoaiKhach,   IDHopDong,
-- TenDichVu,   NgayLamHopDong,   NgayKetThuc,   TongTien  (Với
-- TongTien được tính theo công thức như sau: ChiPhiThue + SoLuong*Gia,
-- với SoLuong và Giá là từ bảng DichVuDiKem) cho tất cả các Khách hàng
-- đã từng đặt phỏng. (Những Khách hàng nào chưa từng đặt phòng cũng
-- phải hiển thị ra)
select
    kh.ma_khach_hang as IDKhachHang,
    kh.ho_ten as HoTen,
    lk.ten_loai_khach as TenLoaiKhach,
    hd.ma_hop_dong as IDHopDong,
    dv.ten_dich_vu as TenDichVu,
    hd.ngay_lam_hop_dong as NgayLamHopDong,
    hd.ngay_ket_thuc as NgayKetThuc,
    SUM(dv.chi_phi_thue + COALESCE(hdct.so_luong, 0) * COALESCE(dvd.gia, 0)) AS TongTien
from khach_hang kh
         left join loai_khach lk on kh.ma_loai_khach = lk.ma_loai_khach
         left join hop_dong hd on kh.ma_khach_hang = hd.ma_khach_hang
         left join dich_vu dv on hd.ma_dich_vu = dv.ma_dich_vu
         left join hop_dong_chi_tiet hdct on hd.ma_hop_dong = hdct.ma_hop_dong
         left join dich_vu_di_kem dvd on hdct.ma_dich_vu_di_kem = dvd.ma_dich_vu_di_kem
group by kh.ma_khach_hang, kh.ho_ten, lk.ten_loai_khach, hd.ma_hop_dong, dv.ten_dich_vu, hd.ngay_lam_hop_dong, hd.ngay_ket_thuc
order by kh.ma_khach_hang;

-- Hiển   thị  IDDichVu,   TenDichVu,   DienTich,   ChiPhiThue,
-- TenLoaiDichVu của tất cả các loại Dịch vụ chưa từng được Khách hàng
-- thực hiện đặt từ quý 1 của năm 2019 (Quý 1 là tháng 1, 2, 3).
select
    dv.ma_dich_vu as IDDichVu,
    dv.ten_dich_vu as TenDichVu,
    dv.dien_tich as DienTich,
    dv.chi_phi_thue as ChiPhiThue,
    ldv.ten_loai_dich_vu as TenLoaiDichVu
from
    dich_vu dv
        join loai_dich_vu ldv on dv.ma_loai_dich_vu = ldv.ma_loai_dich_vu
where
    dv.ma_dich_vu not in (
        select distinct hd.ma_dich_vu
        from hop_dong hd
        where year(hd.ngay_lam_hop_dong) = 2019
          and month(hd.ngay_lam_hop_dong) in (1, 2, 3)
    );

-- Hiển thị thông tin IDDichVu, TenDichVu, DienTich, SoNguoiToiDa,
-- ChiPhiThue, TenLoaiDichVu của tất cả các loại dịch vụ đã từng được
-- Khách hàng đặt phòng trong năm 2018 nhưng chưa từng được Khách
-- hàng đặt phòng  trong năm 2019
select
    dv.ma_dich_vu as  IDDichVu,
    dv.ten_dich_vu as TenDiCHVu,
    dv.dien_tich as DienTich,
    dv.so_nguoi_toi_da as SoNguoiToiDa,
    dv.chi_phi_thue as ChiPhiThue,
    ldv.ten_loai_dich_vu as TenLoaiDichVu
from dich_vu dv
         join loai_dich_vu ldv on dv.ma_loai_dich_vu = ldv.ma_loai_dich_vu
where
    dv.ma_dich_vu in(
        select distinct	hd.ma_dich_vu
        from hop_dong hd
        where year (hd.ngay_lam_hop_dong) = 2020
    )
  and dv.ma_dich_vu not in (
    select distinct hd.ma_dich_vu
    from hop_dong hd
    where year (hd.ngay_lam_hop_dong) = 2021
);
-- Hiển thị thông tin  HoTenKhachHang  có trong hệ thống, với yêu cầu
-- HoThenKhachHang không trùng nhau
-- cach 1
select distinct ho_ten as HoTenKhachhang
from khach_hang;
-- cach 2
select ho_ten as HoTenKhachhang
from khach_hang
group by ho_ten;
-- Thực hiện thống kê doanh thu theo tháng, nghĩa là tương ứng với mỗi tháng
-- trong năm 2019 thì sẽ có bao nhiêu khách hàng thực hiện đặt phòng.
select
    month(hd.ngay_lam_hop_dong) as Thang,
    count(distinct hd.ma_khach_hang) as SoKhachHang
from hop_dong hd
where year(hd.ngay_lam_hop_dong) = 2021
group by month(hd.ngay_lam_hop_dong)
order by Thang;

-- Hiển thị thông tin tương ứng với từng Hợp đồng thì đã sử dụng bao nhiêu
-- Dịch   vụ   đi   kèm.   Kết   quả   hiển   thị   bao   gồm  IDHopDong,
-- NgayLamHopDong,   NgayKetthuc,   TienDatCoc,
-- SoLuongDichVuDiKem  (được   tính   dựa   trên   việc   count   các
-- IDHopDongChiTiet).
select
    hd.ma_hop_dong as IDHopDong,
    hd.ngay_lam_hop_dong as NgayLamHopDong,
    hd.ngay_ket_thuc as NgayKetThuc,
    hd.tien_dat_coc as TienDatCoc,
    count(hdct.ma_hop_dong_chi_tiet) as SoLuongDichVuDiKem
from hop_dong hd
         left join hop_dong_chi_tiet hdct on hd.ma_hop_dong = hdct.ma_hop_dong
group by hd.ma_hop_dong,
         hd.ngay_lam_hop_dong,
         hd.ngay_ket_thuc,
         hd.tien_dat_coc
order by hd.ma_hop_dong;

-- Hiển thị thông tin các Dịch vụ đi kèm đã được sử dụng bởi những Khách
-- hàng có TenLoaiKhachHang là “Diamond” và có địa chỉ là “Vinh”
-- hoặc “Quảng Ngãi”.
select
    dvdk.ma_dich_vu_di_kem AS IDDichVuDiKem,
    dvdk.ten_dich_vu_di_kem AS TenDichVuDiKem
from khach_hang kh
         join loai_khach lk on kh.ma_loai_khach = lk.ma_loai_khach
         join hop_dong hd on kh.ma_khach_hang = hd.ma_khach_hang
         join hop_dong_chi_tiet hdct on hd.ma_hop_dong = hdct.ma_hop_dong
         join dich_vu_di_kem dvdk on hdct.ma_dich_vu_di_kem = dvdk.ma_dich_vu_di_kem
where lk.ten_loai_khach = 'Diamond'
  and (kh.dia_chi LIKE '%Vinh%' OR kh.dia_chi LIKE '%Quảng Ngãi%')
order by dvdk.ma_dich_vu_di_kem;

-- Hiển   thị   thông   tin  IDHopDong,   TenNhanVien,   TenKhachHang,
-- SoDienThoaiKhachHang, TenDichVu, SoLuongDichVuDikem (được
-- tính dựa trên tổng Hợp đồng chi tiết), TienDatCoc của tất cả các dịch vụ đã
-- từng được khách hàng đặt vào 3 tháng cuối năm 2019 nhưng chưa từng
-- được khách hàng đặt vào 6 tháng đầu năm 2019
select
    hd.ma_hop_dong as IDHopDong,
    nv.ho_ten as TenNhanVien,
    kh.ho_ten as TenKhachHang,
    kh.so_dien_thoai as SoDienThoaiKhachHang,
    dv.ten_dich_vu as TenDichVu,
    SUM(hdct.so_luong) as SoLuongDichVuDiKem,
    hd.tien_dat_coc as TienDatCoc
from hop_dong hd
         join nhan_vien nv on hd.ma_nhan_vien = nv.ma_nhan_vien
         join khach_hang kh on hd.ma_khach_hang = kh.ma_khach_hang
         join hop_dong_chi_tiet hdct on hd.ma_hop_dong = hdct.ma_hop_dong
         join dich_vu dv on hdct.ma_dich_vu_di_kem = dv.ma_dich_vu
where
    year(hd.ngay_lam_hop_dong) = 2020
  and month(hd.ngay_lam_hop_dong) in (10,11,12)
  and hd.ma_hop_dong not in(
    select hd1.ma_hop_dong
    from hop_dong hd1
    where year (hd1.ngay_lam_hop_dong) = 2020
      and month(hd1.ngay_lam_hop_dong) in (1, 2, 3, 4, 5, 6)
)
group by hd.ma_hop_dong, nv.ho_ten, kh.ho_ten, kh.so_dien_thoai, dv.ten_dich_vu, hd.tien_dat_coc
order by hd.ma_hop_dong;

-- Hiển thị thông tin các Dịch vụ đi kèm được sử dụng nhiều nhất bởi các
-- Khách hàng đã đặt phòng. (Lưu ý là có thể có nhiều dịch vụ có số lần sử
-- dụng nhiều như nhau)
with dich_vu_su_dung as (
    select
        hdct.ma_dich_vu_di_kem,
        dvdk.ten_dich_vu_di_kem,
        SUM(hdct.so_luong) as tong_so_luong
    from
        hop_dong_chi_tiet hdct
            join dich_vu_di_kem dvdk on hdct.ma_dich_vu_di_kem = dvdk.ma_dich_vu_di_kem
    group by
        hdct.ma_dich_vu_di_kem, dvdk.ten_dich_vu_di_kem
)
select
    ma_dich_vu_di_kem,
    ten_dich_vu_di_kem,
    tong_so_luong
from
    dich_vu_su_dung
where
    tong_so_luong = (select max(tong_so_luong) from dich_vu_su_dung);

-- Hiển thị thông tin tất cả các Dịch vụ đi kèm chỉ mới được sử dụng một lần
-- duy nhất. Thông tin hiển thị bao gồm  IDHopDong,   TenLoaiDichVu,
-- TenDichVuDiKem, SoLanSuDung
select
    hd.ma_hop_dong as IDHopDong,
    ldv.ten_loai_dich_vu as TenLoaiDichVu,
    dvdk.ten_dich_vu_di_kem as TenDichVuDiKem,
    hdct.so_luong as SoLanSuDung
from hop_dong hd
         join dich_vu dv on hd.ma_dich_vu = dv.ma_dich_vu
         join hop_dong_chi_tiet hdct on hd.ma_hop_dong = hdct.ma_hop_dong
         join dich_vu_di_kem dvdk on hdct.ma_dich_vu_di_kem = dvdk.ma_dich_vu_di_kem
         join loai_dich_vu ldv on dv.ma_loai_dich_vu = ldv.ma_loai_dich_vu
where hdct.so_luong = 1
order by hd.ma_hop_dong;

-- Hiển thi thông tin của tất cả nhân viên bao gồm IDNhanVien, HoTen,
-- TrinhDo, TenBoPhan, SoDienThoai, DiaChi mới chỉ lập được tối đa 3
-- hợp đồng từ năm 2018 đến 2019.
select
    nv.ma_nhan_vien as IDNhanVien,
    nv.ho_ten as HoTen,
    td.ten_trinh_do as TrinhDo,
    bp.ten_bo_phan as TenBoPhan,
    nv.so_dien_thoai as SoDienThoai,
    nv.dia_chi as DiaChi
from nhan_vien nv
         join trinh_do td on nv.ma_trinh_do = td.ma_trinh_do
         join bo_phan bp on nv.ma_bo_phan = bp.ma_bo_phan
where
    nv.ma_nhan_vien in(
        select hd.ma_nhan_vien
        from hop_dong hd
        where year(hd.ngay_lam_hop_dong) between 2020 and 2021
        group by hd.ma_nhan_vien
        having count(hd.ma_hop_dong) <=3
    );

-- Xóa những Nhân viên chưa từng lập được hợp đồng nào từ năm 2017 đến năm 2019.
SET SQL_SAFE_UPDATES = 0;
delete from nhan_vien
where ma_nhan_vien not in (
    select hd.ma_nhan_vien
    from hop_dong hd
    where year(hd.ngay_lam_hop_dong) between 2019 and 2021
);
SET SQL_SAFE_UPDATES = 1;

-- Cập nhật thông tin những khách hàng có  TenLoaiKhachHang   từ
-- Platinium  lên  Diamond, chỉ cập nhật những khách hàng đã từng đặt
-- phòng với tổng Tiền thanh toán trong năm 2019 là lớn hơn 10.000.000VNĐ
UPDATE Khach_Hang AS kh
    JOIN (
        SELECT kh.ma_khach_hang,kh.ho_ten,lk.ten_loai_khach,hd.ma_hop_dong,dv.ten_dich_vu,hd.ngay_lam_hop_dong,hd.ngay_ket_thuc,
               (COALESCE(dv.chi_phi_thue,0)  + COALESCE(sum(hdct.so_luong * dvd.gia),0)) AS TongTien
        FROM Khach_Hang kh
                 LEFT JOIN Hop_Dong hd ON kh.ma_khach_hang = hd.ma_khach_hang
                 LEFT JOIN Dich_Vu dv ON hd.ma_dich_vu = dv.ma_dich_vu
                 LEFT JOIN Loai_Khach lk ON kh.ma_loai_khach = lk.ma_loai_khach
                 LEFT JOIN Hop_Dong_Chi_Tiet hdct ON hd.ma_hop_dong = hdct.ma_hop_dong
                 LEFT JOIN Dich_Vu_Di_Kem dvd ON hdct.ma_dich_vu_di_kem= dvd.ma_dich_vu_di_kem
        WHERE lk.ten_loai_khach = 'Platinium' AND YEAR(hd.ngay_lam_hop_dong) = 2021
        group by kh.ma_khach_hang,hd.ma_hop_dong
        having TongTien > 10000000) AS ku  ON kh.ma_khach_hang = ku.ma_khach_hang
SET kh.ma_loai_khach = 1      -- ID của loại Diamond
WHERE kh.ma_loai_khach = 2; -- ID của loại Platinum

-- Xóa những khách hàng có hợp đồng trước năm 2016
delete kh
from khach_hang kh
         join hop_dong hd on kh.ma_khach_hang = hd.ma_khach_hang
where year(hd.ngay_lam_hop_dong) < 2016;

-- Cập nhật giá cho các Dịch vụ đi kèm được sử dụng trên 10 lần trong năm 2019 lên gấp đôi.
SET SQL_SAFE_UPDATES = 0;

select hdct.ma_dich_vu_di_kem
from hop_dong_chi_tiet hdct
         join hop_dong hd on hdct.ma_hop_dong = hd.ma_hop_dong
where year(hd.ngay_lam_hop_dong) = 2021
group by hdct.ma_dich_vu_di_kem
having count(*) > 10;
update dich_vu_di_kem dvdk
    join (
        select hdct.ma_dich_vu_di_kem
        from hop_dong_chi_tiet hdct
                 join hop_dong hd on hdct.ma_hop_dong = hd.ma_hop_dong
        where year(hd.ngay_lam_hop_dong) = 2021
        group by hdct.ma_dich_vu_di_kem
        having COUNT(*) > 10
    ) as dvdk_update on dvdk.ma_dich_vu_di_kem = dvdk_update.ma_dich_vu_di_kem
set dvdk.gia = dvdk.gia * 2;
SET SQL_SAFE_UPDATES = 0;

-- Hiển thị thông tin của tất cả các Nhân viên và Khách hàng có trong hệ
-- thống, thông tin hiển thị bao gồm  ID   (IDNhanVien,   IDKhachHang),
-- HoTen, Email, SoDienThoai, NgaySinh, DiaChi.
select
    nv.ma_nhan_vien as IDNhanVien,
    null as IDKhachHang,
    nv.ho_ten as HoTen,
    nv.email as Email,
    nv.so_dien_thoai as SoDienThoai,
    nv.ngay_sinh as NgaySinh,
    nv.dia_chi as DiaChi
from nhan_vien nv
union all
select
    null as IDNhanVien,
    kh.ma_khach_hang as IDKhachHang,
    kh.ho_ten as HoTen,
    kh.email as Email,
    kh.so_dien_thoai as SoDienThoai,
    kh.ngay_sinh as NgaySinh,
    kh.dia_chi as DiaChi
from khach_hang kh;

# 21.	Tạo khung nhìn có tên là v_nhan_vien để lấy được thông tin của tất cả các nhân viên có địa chỉ là “Hải Châu”
#       và đã từng lập hợp đồng cho một hoặc nhiều khách hàng bất kì với ngày lập hợp đồng là “12/12/2019”.
Drop view if exists v_nhan_vien;
CREATE VIEW v_nhan_vien AS
SELECT nv.ma_nhan_vien,nv.Ho_Ten,nv.Email,nv.so_dien_thoai,nv.ngay_sinh,nv.dia_chi
FROM Nhan_Vien nv
         JOIN Hop_Dong hd ON nv.ma_nhan_vien = hd.ma_nhan_vien
WHERE nv.dia_chi LIKE '%Đà Nẵng%'



