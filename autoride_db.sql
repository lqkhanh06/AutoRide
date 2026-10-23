-- =======================================================================
-- HỆ THỐNG QUẢN LÝ THUÊ XE TỰ LÁI AUTORIDE
-- File: autoride_db.sql
-- Mô tả: DDL tái cấu trúc CSDL và DML mô phỏng quy trình kiểm tra xe, tính phí phạt
-- =======================================================================

DROP DATABASE IF EXISTS autoride_db;
CREATE DATABASE autoride_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE autoride_db;

-- -----------------------------------------------------------------------
-- PHẦN 1: TẠO CẤU TRÚC BẢNG (DDL)
-- -----------------------------------------------------------------------

-- 1. Bảng Xe (Cars)
CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

-- 2. Bảng Hợp đồng thuê xe (Rentals) - Đã nâng cấp chuẩn hóa
-- Khóa chặt vòng đời bằng ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED')
-- Bổ sung đầy đủ các cột tài chính dùng kiểu DECIMAL(12, 2) chống sai số làm tròn
CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME NULL,
    status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'BOOKED',
    security_deposit DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (security_deposit >= 0),
    late_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (late_fee >= 0),
    damage_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (damage_fee >= 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES Cars(car_id)
);

-- 3. Bảng Biên bản kiểm tra xe (Inspections) - Khắc phục thiếu hụt của CSDL cũ
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT NULL,
    inspector_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------
-- PHẦN 2: TRIGGER BẢO VỆ TOÀN VẸN DỮ LIỆU TẦNG CSDL (NÂNG CAO)
-- Ngăn chặn nhân viên tạo biên bản kiểm tra khi khách chưa nhận xe (status = 'BOOKED')
-- -----------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_before_insert_inspection
BEFORE INSERT ON Inspections
FOR EACH ROW
BEGIN
    DECLARE current_status VARCHAR(20);
    
    SELECT status INTO current_status
    FROM Rentals
    WHERE rental_id = NEW.rental_id;
    
    IF current_status = 'BOOKED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Hợp đồng đang ở trạng thái BOOKED (chưa nhận xe), không thể tạo biên bản kiểm tra trả xe!';
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------
-- PHẦN 3: DỮ LIỆU DANH MỤC XE BAN ĐẦU
-- -----------------------------------------------------------------------
INSERT INTO Cars (model_name, license_plate) VALUES 
('Toyota Fortuner 2023', '30G-888.99'),
('Hyundai SantaFe 2024', '51K-666.88'),
('VinFast VF8 2024', '29A-999.11');

-- -----------------------------------------------------------------------
-- PHẦN 4: DML MÔ PHỎNG QUY TRÌNH THUÊ - TRẢ XE THỰC TẾ
-- -----------------------------------------------------------------------

-- Bước 1: Khách hàng "Nguyen Van A" thuê xe Toyota Fortuner (car_id = 1)
-- Đóng tiền cọc 10.000.000 VNĐ, trạng thái chuyển sang ACTIVE khi nhận xe
INSERT INTO Rentals (car_id, customer_name, rent_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-10-20 08:00:00', 'ACTIVE', 10000000.00);

-- Bước 2: Khách trả xe ngày 2026-10-23
-- Nhân viên kỹ thuật "Tran Van Kiem" kiểm tra và phát hiện xe vỡ đèn pha trái
INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
VALUES (1, '2026-10-23 17:30:00', 'Vỡ cụm đèn pha bên trái, xước nhẹ cản trước', 'Tran Van Kiem');

-- Bước 3: Cập nhật hợp đồng Rentals: Trạng thái COMPLETED
-- Ghi nhận: Không trễ hạn (late_fee = 0), Phí bồi thường hư hỏng (damage_fee = 2.000.000 VNĐ)
UPDATE Rentals 
SET status = 'COMPLETED',
    return_date = '2026-10-23 17:30:00',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = 1;

-- -----------------------------------------------------------------------
-- PHẦN 5: TRUY VẤN TÍNH TOÁN TIỀN HOÀN TRẢ VÀ ĐỐI SOÁT TÀI CHÍNH
-- Công thức: Tiền hoàn trả = Tiền cọc - Phí phạt trễ - Phí sửa chữa hư hỏng
-- -----------------------------------------------------------------------
SELECT 
    r.rental_id,
    r.customer_name,
    c.model_name,
    c.license_plate,
    r.rent_date,
    r.return_date,
    r.status,
    i.inspector_name,
    i.damage_description,
    r.security_deposit AS tien_dat_coc,
    r.late_fee AS phi_tre_han,
    r.damage_fee AS phi_sua_chua_hu_hong,
    (r.security_deposit - r.late_fee - r.damage_fee) AS tien_thuc_hoan_tra_cho_khach
FROM Rentals r
JOIN Cars c ON r.car_id = c.car_id
LEFT JOIN Inspections i ON r.rental_id = i.rental_id
WHERE r.rental_id = 1;
